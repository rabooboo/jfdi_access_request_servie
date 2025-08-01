import Fluent
import Vapor

func routes(_ app: Application) throws {
    
    guard let communityURLString = Environment.get("COMMUNITY_SERVICE_URL") else {
        throw JFDIError.environmentVaribaleMissing(variableName: "COMMUNITY_SERVICE_URL")
    }

    try app.register(collection: JoinRequestController(communityURLString: communityURLString))
}
