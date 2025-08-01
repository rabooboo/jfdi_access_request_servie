//
//  AuthMiddleware.swift
//  jufudoo_ruleoutservice
//
//  Created by Tom Eichhorn on 20.11.24.
//
import Vapor
import Foundation

// Middleware responsible for authenticating users
final class UserAuthMiddleware: AsyncMiddleware {
    
    // The main method of the middleware that intercepts each incoming request
    func respond(to request: Vapor.Request, chainingTo next: any Vapor.AsyncResponder) async throws -> Vapor.Response {
        
        // Check if a Bearer token is present in the request header
        guard let token = request.headers.bearerAuthorization?.token else {
            // If the token is missing, return a 401 Unauthorized response
            throw Abort(.unauthorized, reason: "Authorization token missing")
        }
        
        // Try to retrieve user information from the cache if the token has been used before
        if let cachedUserInfo = try await request.cache.get(token, as: User.self) {
            // If the token is in the cache and valid, authenticate the user in the request
            request.auth.login(cachedUserInfo)
            // Pass the request to the next middleware handler
            return try await next.respond(to: request)
        }
        
        // If the token is not in the cache, verify it with the user service
        do {
            guard let validationURLString = Environment.get("USER_SERVICE_VALIDATE_URL") else {
                throw JFDIError.environmentVaribaleMissing(variableName: "USER_SERVICE_VALIDATE_URL")
            }

            // Create URI from the URL string
            let validationURI = URI(string: validationURLString)

            // Create HTTP headers
            let headers = HTTPHeaders([
                ("Authorization", "Bearer \(token)"),
                ("Content-Type", "application/json")
            ])

            // Perform the request
            let clientResponse = try await request.client.get(validationURI, headers: headers)

            // Check the response status
            guard clientResponse.status == .ok else {
                // Log the error or throw a custom error
                throw Abort(.badRequest, reason: "Failed validation request with status: \(clientResponse.status)")
            }

            // Decode the response body into TokenValidation
            guard let _ = clientResponse.body else {
                throw Abort(.internalServerError, reason: "Empty response body from validation service.")
            }

            do {
                let tokenValidationResponse = try clientResponse.content.decode(TokenValidationResponse.self)
                let validatedUser = tokenValidationResponse.user
                let expiry = tokenValidationResponse.expiry
                
                // Cache the user info for future requests
                try await request.cache.set(token, to: validatedUser, expiresIn: .seconds(Int(expiry.timeIntervalSinceNow)))

                // Authenticate the user in the request
                request.auth.login(validatedUser)

                
            } catch {
                throw Abort(.internalServerError, reason: "Failed to decode TokenValidation response: \(error.localizedDescription)")
            }
            // Pass the request to the next middleware handler
            return try await next.respond(to: request)
        }
    }
}

struct TokenValidationResponse: Content {
    let user: User
    let expiry: Date
}
