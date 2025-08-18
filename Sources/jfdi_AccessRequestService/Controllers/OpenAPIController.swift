//
//  FileController.swift
//
//
//  Created by Tom Eichhorn on 25.08.23.
//

import Foundation
import Vapor
import VaporToOpenAPI

struct OpenAPIController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        routes.get("swagger", "swagger.json") { req in
          req.application.routes.openAPI(
            info: InfoObject(
              title: "Aloliana Access Request Service",
              description: "This API is used as a access request service for Aloliana.",
              version: Version(0,1,0)
            )
          )
        }
        .excludeFromOpenAPI()
    }
}
