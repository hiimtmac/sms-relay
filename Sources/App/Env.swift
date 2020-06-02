import Foundation

enum Env: String {
    case RELAY_AWS_ACCESS_KEY_ID
    case RELAY_AWS_SECRET_ACCESS_KEY
    case RELAY_DESTINATION_NUMBER
    case RELAY_PINPOINT_APPLICATION_ID
}

extension Dictionary where Key == String, Value == String {
    subscript(_ key: Env) -> String {
        guard let value = self[key.rawValue] else {
            fatalError("Missing environment: \(key.rawValue)")
        }
        
        return value
    }
}

var env: [String: String] { ProcessInfo.processInfo.environment }
