import Foundation

enum Error: Swift.Error, LocalizedError {
    case missingEnvironment(key: String)
    case missingMessage
    case badResponse
    case unsuccessful(message: String)
    
    var errorDescription: String? {
        switch self {
        case .missingEnvironment(let key): return "Missing Environment: \(key)"
        case .missingMessage: return "Missing Message"
        case .badResponse: return "Bad Response"
        case .unsuccessful(let message): return "Unsucessfull \(message)"
        }
    }
}
