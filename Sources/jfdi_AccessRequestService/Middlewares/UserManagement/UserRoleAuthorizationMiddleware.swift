//
//  File.swift
//  
//
//  Created by Patrick-Benjamin Bök on 13.08.23.
//
import Vapor

struct UserRoleAuthorizationMiddleware: AsyncMiddleware {
   
    let requiredRole: UserRole

    func respond(to request: Vapor.Request, chainingTo next: any Vapor.AsyncResponder) async throws -> Vapor.Response {
        
        // Ensure user is authenticated
        guard let user = request.auth.get(User.self) else {
            throw Abort(.unauthorized)
        }
                
        // Check the user's role
        guard user.role == requiredRole else {
                throw Abort(.forbidden)
        }
        
        // Continue to the next responder
        return try await next.respond(to: request)
    }
}

