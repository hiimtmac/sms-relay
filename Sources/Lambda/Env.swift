import Foundation

enum Env: String {
    case OWNER_NUMBER
    case RELAY_NUMBER
    case PINPOINT_APP_ID
}

extension Dictionary where Key == String, Value == String {
    func get(_ key: Env) throws -> String {
        guard let value = self[key.rawValue] else {
            throw LambdaError.missingEnvironment(key.rawValue)
        }
        
        return value
    }
}

var env: [String: String] { ProcessInfo.processInfo.environment }
