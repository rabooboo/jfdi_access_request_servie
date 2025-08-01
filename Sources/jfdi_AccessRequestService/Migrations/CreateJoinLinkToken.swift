//
//  CreateJoinLinkToken.swift
//  jfdi_AccessRequestService
//
//  Created by Tom Eichhorn on 29.06.25.
//

import Fluent

struct CreateJoinLinkToken: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema("join_link_tokens")
            .id()
            .field("token", .string, .required)
            .field("target_type", .string, .required)
            .field("target_id", .uuid, .required)
            .field("creator_id", .uuid, .required)
            .field("expires_at", .datetime, .required)
            .field("created_at", .datetime)
            .unique(on: "token")
            .create()
    }

    func revert(on database: any Database) async throws {
        try await database.schema("join_link_tokens").delete()
    }
}
