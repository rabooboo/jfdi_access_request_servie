//
//  JoinLinkToken.swift
//  jfdi_AccessRequestService
//
//  Created by Tom Eichhorn on 29.06.25.
//

import Vapor
import Fluent

final class JoinLinkToken: Model, @unchecked Sendable, Content {
    static let schema = "join_link_tokens"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "token")
    var token: String

    @Field(key: "target_type")
    var targetType: JoinRequestTargetType

    @Field(key: "target_id")
    var targetID: UUID

    @Field(key: "creator_id")
    var creator: UUID

    @Field(key: "expires_at")
    var expiresAt: Date

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    init() {}

    init(token: String, targetType: JoinRequestTargetType, targetID: UUID, creatorID: UUID, expiresAt: Date) {
        self.token = token
        self.targetType = targetType
        self.targetID = targetID
        self.creator = creatorID
        self.expiresAt = expiresAt
    }
}
