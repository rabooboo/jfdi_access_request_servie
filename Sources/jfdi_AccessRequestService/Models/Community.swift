//
//  Community.swift
//  aloliana
//
//  Created by Patrick-Benjamin Bök on 30.12.24.
//
import Fluent
import Vapor

struct Community: Content {
    
    var id: UUID
    var name: String
    var kennelID: UUID
    
    var created: Date?
    var updated: Date?
    var deleted: Date?
    
    var readPermissions: [UUID]
    var writePermissions: [UUID]
    
    
    init(id: UUID, name: String, kennelID: UUID) {
        self.id = id
        self.name = name
        self.kennelID = kennelID
        self.readPermissions = []
        self.writePermissions = []
    }
}

struct CommunityCreateData: Content {
    let name: String
    let kennelID: UUID
    let readPermissions: [UUID]?
    let writePermissions: [UUID]?
}

struct CommunityUpdateData: Content{
    let name: String?
    let readPermissions: [UUID]?
    let writePermissions: [UUID]?
}
