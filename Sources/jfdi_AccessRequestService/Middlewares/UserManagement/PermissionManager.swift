//
//  PermissionManager.swift
//  
//
//  Created by Patrick-Benjamin Bök on 13.08.23.
//
import Vapor

protocol PermissionManager{
    var readPermissions: [UUID] {get set}
    var writePermissions: [UUID] {get set}
}

extension PermissionManager{
    
//    func isOwner(requestingOwnerID: User.IDValue) -> Bool{
//        return self.owner.id == requestingOwnerID
//    }
    
    func canRead(userID: UUID) throws -> Bool{
        if let _ = readPermissions.first(where: { $0 == userID }) {
           return true
        }
        return false
    }
    
    func canWrite(userID: UUID) -> Bool{
        if let _ = writePermissions.first(where: { $0 == userID }) {
           return true
        }
        return false
    }
    
    mutating func addReadPermissions(userID: UUID){
        if let _ = readPermissions.first(where: { $0 == userID }) {
        }
        else{
            readPermissions.append(userID)
        }
    }
    
    mutating func addWritePermissions(userID: UUID){
        if let _ = writePermissions.first(where: { $0 == userID }) {
        }
        else{
            writePermissions.append(userID)
        }
    }
    
    mutating func deleteReadPermissions(userID: UUID){
        if let index = writePermissions.firstIndex(of: userID) {
            writePermissions.remove(at: index)
        }
    }
    
    mutating func deleteWritePermissions(userID: UUID){
        if let index = readPermissions.firstIndex(of: userID) {
            readPermissions.remove(at: index)
        }
    }
}
