////
////  RESTHandler.swift
////
////
////  Created by Patrick-Benjamin Bök on 19.08.23.
////
import Foundation
import AsyncHTTPClient
import NIO
import NIOFoundationCompat
import NIOHTTP1

class RESTHandler {
    
    private let httpClient: AsyncHTTPClient.HTTPClient
    private let eventLoopGroup: any EventLoopGroup
    
    init() {
        self.eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        self.httpClient = AsyncHTTPClient.HTTPClient(eventLoopGroupProvider: .shared(eventLoopGroup))
    }
    
    // Perform a generic HTTP request
    func performRESTRequest(urlPath: String, method: HTTPMethod, httpHeaders: [String: String]? = nil, body: ByteBuffer? = nil) async throws -> (AsyncHTTPClient.HTTPClientResponse, String?) {
        
        guard let _ = URL(string: urlPath) else {
            throw JFDIError.invalidPathOrURL
        }

        var request = HTTPClientRequest(url: urlPath)
        request.method = method
        if let httpHeaders = httpHeaders {
            for (key, value) in httpHeaders {
                request.headers.add(name: key, value: value)
            }
        }
        request.headers.add(name: "Content-Type", value: "application/json")
        request.body = body.map { .bytes($0) }
        
        let response = try await httpClient.execute(request, timeout: .seconds(30))
        let data = try await response.body.collect(upTo: 1024 * 1024) // Limit to 1MB
        let content = data.getString(at: 0, length: body?.readableBytes ?? 0, encoding: .utf8)

        print("Response content: \(content ?? "No content available")")
        print("Response status: \(response.status)")

        try await self.shutdown()
        return (response, content)
    }

    // Method to fetch JSON data from a given URL
    func fetchJSONAsString(from urlString: String) async throws -> String? {
        guard let _ = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        var request = HTTPClientRequest(url: urlString)
        request.method = .GET
        request.headers.add(name: "Accept", value: "application/json")
        
        let response = try await httpClient.execute(request, timeout: .seconds(10))
        
        guard response.status == .ok else {
            throw URLError(.badServerResponse)
        }
        
        let data = try await response.body.collect(upTo: 1024 * 1024)
        
        if let jsonString = data.getString(at: 0, length: data.readableBytes, encoding: .utf8) {
            return jsonString
        } else {
            throw URLError(.cannotParseResponse)
        }
    }

    func shutdown() async throws {
        try await httpClient.shutdown()
        try await eventLoopGroup.shutdownGracefully()
    }
}


