#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif

enum LambdaError: Error, LocalizedError {
    case missingEnvironment(String)
    case missingMessage
    
    var errorDescription: String? {
        switch self {
        case .missingEnvironment(let key): return "Missing Environment: \(key)"
        case .missingMessage: return "Missing Message"
        }
    }
}
