//
//  Request.swift
//  aloliana
//
//  Created by Patrick-Benjamin Bök on 09.01.25.
//
import Vapor

extension Request {
    func requireUserID() throws -> UUID {
        
        guard
            let userIDString = self.query[String.self, at: "userID"],
            let userID = UUID(uuidString: userIDString)
        else {
            throw Abort(.unauthorized, reason: "Missing or invalid userID in query.")
        }
        return userID
    }
}
