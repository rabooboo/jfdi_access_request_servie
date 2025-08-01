//
//  JFDIError.swift
//
//
//  Created by Patrick-Benjamin Bök on 18.08.23.
//
import Foundation

//Enumeration of own errortypes
public enum JFDIError: Error{
    case parseError
    case httpStatusError
    case URLError
    case invalidPathOrURL
    case jsonBodyEncodingError
    case jsonBodyDecodingError
    case environmentVaribaleMissing(variableName: String)
    case genericError(message: String)
    
}

//Localized error description for each of the error types defined in the enumeration
extension JFDIError: LocalizedError{
    
    public var errorDescription: String?{
        switch self {
        case .parseError:
            return NSLocalizedString("Error parsing something.", comment: "Parse Error")
        case .invalidPathOrURL:
            return NSLocalizedString("Selected path or URL invalied.", comment: "HTTP Error")
        case .httpStatusError:
            return NSLocalizedString("HTTP status not 200.", comment: "HTTP Error")
        case .jsonBodyEncodingError:
            return NSLocalizedString("JSON HTTP body encoding failed.", comment: "Coding Error")
        case .jsonBodyDecodingError:
            return NSLocalizedString("JSON HTTP body decoding failed.", comment: "Coding Error")
        case .URLError:
            return NSLocalizedString("Error while generating URL.", comment: "URL Error")
        case .environmentVaribaleMissing(let variableName):
            return NSLocalizedString("Environment variable '\(variableName)' is missing.", comment: "Environment Error")
        case .genericError(let message):
            return NSLocalizedString("\(message)", comment: "Generic Error")
        }
    }
}
