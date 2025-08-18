//
//  JoinRequest.swift
//  jfdi_AccessRequestService
//
//  Created by Tom Eichhorn on 29.06.25.
//

import Vapor
import Fluent

enum JoinRequestTargetType: String, Codable {
    case community
}

enum JoinRequestStatus: String, Codable {
    case pending
    case approved
    case rejected
}

final class JoinRequest: Model, @unchecked Sendable, Content {
    static let schema = "join_requests"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "target_id")
    var targetID: UUID

    @Field(key: "target_type")
    var targetType: JoinRequestTargetType

    @Field(key: "requester_id")
    var requester: UUID

    @OptionalField(key: "message")
    var message: String?

    @Field(key: "status")
    var status: JoinRequestStatus

    @Field(key: "token")
    var token: String

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    init() {}

    init(id: UUID? = nil, targetID: UUID, targetType: JoinRequestTargetType, requesterID: UUID, message: String?, token: String) {
        self.id = id
        self.targetID = targetID
        self.targetType = targetType
        self.requester = requesterID
        self.message = message
        self.status = .pending
        self.token = token
    }
}

struct JoinRequestOpenAPI: Content {
    let id: UUID?
    let targetID: UUID
    let targetType: JoinRequestTargetType
    let requester: UUID
    let message: String?
    let status: JoinRequestStatus
    let token: String
    let createdAt: Date?
}
