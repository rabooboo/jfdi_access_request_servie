//
//  JoinRequestController.swift
//  jfdi_AccessRequestService
//
//  Created by Tom Eichhorn on 29.06.25.
//

import Vapor
import Fluent

struct JoinRequestController: RouteCollection {
    
    // MARK: - Properties
    let communityURLString: String  // Community-URL des Community Services
    
    func boot(routes: any RoutesBuilder) throws {
        
        let joinTokenAuthGroup = routes.grouped(UserAuthMiddleware()).grouped("v1")
        let joinRoutes = joinTokenAuthGroup.grouped("join")

        joinRoutes.post(":targetType", ":targetID", "submit", use: submitJoinRequest)

        joinRoutes.post("link", use: generateJoinLink)
        joinRoutes.get("requests", use: listJoinRequests)
        joinRoutes.post("requests", ":id", "approve", use: approveJoinRequest)
        joinRoutes.post("requests", ":id", "reject", use: rejectJoinRequest)
    }

    // MARK: - Anfrage absenden
    func submitJoinRequest(req: Request) async throws -> HTTPStatus {
        struct Input: Content {
            var message: String?
            var token: String
        }

        let input = try req.content.decode(Input.self)
        let user = try req.auth.require(User.self)
        let (targetType, targetID, _) = try parseParams(req)

        guard try await isValidToken(input.token, targetType: targetType, targetID: targetID, req: req) else {
            throw Abort(.unauthorized)
        }

        let joinRequest = JoinRequest(
            targetID: targetID,
            targetType: targetType,
            requesterID: user.id,
            message: input.message,
            token: input.token
        )

        try await joinRequest.save(on: req.db)
        return .created
    }

    // MARK: - Join-Link generieren
    func generateJoinLink(req: Request) async throws -> JoinLinkResponse {
        struct JoinLinkInput: Content {
            var targetType: JoinRequestTargetType
            var targetID: UUID
            var expiresInHours: Int?
        }

        let input = try req.content.decode(JoinLinkInput.self)
        let user = try req.auth.require(User.self)
        
        // Zugriffsprüfung
        let hasWriteAccess = try await userHasWriteAccess(
            to: input.targetType,
            targetID: input.targetID,
            userID: user.id,
            req: req
        )

        guard hasWriteAccess else {
            throw Abort(.forbidden, reason: "User has no write access to this target")
        }

        let token = [UUID().uuidString, UUID().uuidString].joined(separator: "-")
        let expiration = Date().addingTimeInterval(Double(input.expiresInHours ?? 48) * 3600)

        let tokenModel = JoinLinkToken(
            token: token,
            targetType: input.targetType,
            targetID: input.targetID,
            creatorID: user.id,
            expiresAt: expiration
        )

        try await tokenModel.save(on: req.db)

        let link = "https://aloliana.jufudoo.cloud/join/\(input.targetType.rawValue)/\(input.targetID)?token=\(token)"
        return .init(deepLink: link, expiresAt: expiration)
    }

    // MARK: - Liste der JoinRequests
    func listJoinRequests(req: Request) async throws -> [JoinRequest] {
        let user = try req.auth.require(User.self)

        // Query-Parameter lesen
        guard
            let targetTypeRaw = try? req.query.get(String.self, at: "targetType"),
            let targetType = JoinRequestTargetType(rawValue: targetTypeRaw),
            let targetID = try? req.query.get(UUID.self, at: "targetID")
        else {
            throw Abort(.badRequest, reason: "targetType and targetID query parameters are required")
        }

        // Zugriffsprüfung
        let hasWriteAccess = try await userHasWriteAccess(
            to: targetType,
            targetID: targetID,
            userID: user.id,
            req: req
        )

        guard hasWriteAccess else {
            throw Abort(.forbidden, reason: "User has no write access to this target")
        }

        // Nur JoinRequests für dieses Target abrufen
        return try await JoinRequest.query(on: req.db)
            .filter(\.$targetType == targetType)
            .filter(\.$targetID == targetID)
            .filter(\.$status == .pending)
            .all()
    }


    // MARK: - Anfrage genehmigen
    func approveJoinRequest(req: Request) async throws -> HTTPStatus {
        let id = try req.parameters.require("id", as: UUID.self)
        let user = try req.auth.require(User.self)
        
        guard let request = try await JoinRequest.find(id, on: req.db) else {
            throw Abort(.notFound)
        }
        
        // Zugriffsprüfung
        let hasWriteAccess = try await userHasWriteAccess(
            to: request.targetType,
            targetID: request.targetID,
            userID: user.id,
            req: req
        )

        guard hasWriteAccess else {
            throw Abort(.forbidden, reason: "User has no write access to this target")
        }

        request.status = .approved
        try await request.save(on: req.db)

        try await linkRequesterToTarget(request, req: req)
        return .ok
    }

    // MARK: - Anfrage ablehnen
    func rejectJoinRequest(req: Request) async throws -> HTTPStatus {
        let id = try req.parameters.require("id", as: UUID.self)
        let user = try req.auth.require(User.self)
        
        guard let request = try await JoinRequest.find(id, on: req.db) else {
            throw Abort(.notFound)
        }
        
        // Zugriffsprüfung
        let hasWriteAccess = try await userHasWriteAccess(
            to: request.targetType,
            targetID: request.targetID,
            userID: user.id,
            req: req
        )

        guard hasWriteAccess else {
            throw Abort(.forbidden, reason: "User has no write access to this target")
        }

        request.status = .rejected
        try await request.save(on: req.db)
        return .ok
    }

    // MARK: - Hilfsfunktionen

    private func parseParams(_ req: Request) throws -> (JoinRequestTargetType, UUID, String) {
        guard let typeStr = req.parameters.get("targetType"),
              let type = JoinRequestTargetType(rawValue: typeStr),
              let idStr = req.parameters.get("targetID"),
              let id = UUID(uuidString: idStr),
              let token = try? req.query.get(String.self, at: "token") else {
            throw Abort(.badRequest)
        }
        return (type, id, token)
    }

    private func isValidToken(_ token: String, targetType: JoinRequestTargetType, targetID: UUID, req: Request) async throws -> Bool {
        guard let entry = try await JoinLinkToken
            .query(on: req.db)
            .filter(\.$token == token)
            .filter(\.$targetType == targetType)
            .filter(\.$targetID == targetID)
            .first() else {
                return false
            }

        return entry.expiresAt > Date()
    }
    
    private func userHasWriteAccess(to targetType: JoinRequestTargetType, targetID: UUID, userID: UUID, req: Request) async throws -> Bool {
        guard let token = req.headers.bearerAuthorization?.token else {
            throw Abort(.unauthorized, reason: "Authorization token missing")
        }

        switch targetType {
        case .community:
            let uri = URI(string: "\(communityURLString)/communities/\(targetID)")
            let headers = HTTPHeaders([
                ("Authorization", "Bearer \(token)"),
                ("Content-Type", "application/json")
            ])

            let response = try await req.client.get(uri, headers: headers)
            guard response.status == .ok else {
                throw Abort(.badRequest, reason: "Failed requesting community with status: \(response.status)")
            }

            let community = try response.content.decode(Community.self)
            return community.writePermissions.contains(userID)
        }
    }


    private func linkRequesterToTarget(_ joinRequest: JoinRequest, req: Request) async throws {
        switch joinRequest.targetType {
        case .community:
            guard let token = req.headers.bearerAuthorization?.token else {
                throw Abort(.unauthorized, reason: "Authorization token missing")
            }

            let requestURI = URI(string: "\(communityURLString)/communities/\(joinRequest.targetID)")
            let headers = HTTPHeaders([
                ("Authorization", "Bearer \(token)"),
                ("Content-Type", "application/json"),
            ])

            let clientResponse = try await req.client.get(requestURI, headers: headers)
            guard clientResponse.status == .ok else {
                throw Abort(.badRequest, reason: "Failed requesting community with status: \(clientResponse.status)")
            }

            var community = try clientResponse.content.decode(Community.self)

            // Append requester to readPermissions if not already present
            if !community.readPermissions.contains(joinRequest.requester) {
                community.readPermissions.append(joinRequest.requester)
            }

            // Prepare update payload
            let updateData = CommunityUpdateData(
                name: nil,
                readPermissions: community.readPermissions,
                writePermissions: nil
            )

            // Send PATCH with CommunityUpdateData
            let patchResponse = try await req.client.patch(requestURI, headers: headers) { patchReq in
                try patchReq.content.encode(updateData)
            }

            guard patchResponse.status == .ok else {
                throw Abort(.badRequest, reason: "Failed to update community: \(patchResponse.status)")
            }
        }
    }
}

struct JoinLinkResponse: Content {
    let deepLink: String
    let expiresAt: Date
}
