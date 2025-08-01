//
//  CreateJoinRequest.swift
//  jfdi_AccessRequestService
//
//  Created by Tom Eichhorn on 29.06.25.
//

import Fluent

struct CreateJoinRequest: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema("join_requests")
            .id()
            .field("target_id", .uuid, .required)
            .field("target_type", .string, .required)
            .field("requester_id", .uuid, .required)
            .field("message", .string)
            .field("status", .string, .required)
            .field("token", .string, .required)
            .field("created_at", .datetime)
            .create()
    }

    func revert(on database: any Database) async throws {
        try await database.schema("join_requests").delete()
    }
}
