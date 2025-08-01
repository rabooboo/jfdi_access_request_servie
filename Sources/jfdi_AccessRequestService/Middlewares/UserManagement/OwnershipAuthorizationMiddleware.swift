//
//  File.swift
//  
//
//  Created by Patrick-Benjamin Bök on 13.08.23.
//

import Vapor

//struct OwnershipAuthorizationMiddleware: AsyncMiddleware {
//  
//    func respond(to request: Vapor.Request, chainingTo next: Vapor.AsyncResponder) async throws -> Vapor.Response {
//        
//        guard let user = request.auth.get(User.self), let userID = user.id else {
//            throw Abort(.unauthorized)
//        }
//
//        let parameters = try request.parameters.requireResolved(for: Ownable.self)
//        let resourceID = try parameters.get(ObjectId.self, at: "ownerID")
//
//        let ownables = try await request.db.query(Ownable.self)
//            .filter(\.$id == resourceID)
//            .all()
//
//        guard let ownable = ownables.first, ownable.ownerID == userID else {
//            throw Abort(.forbidden, reason: "You don't own this resource.")
//        }
//
//        return try await next.respond(to: request)
//    }
//}

