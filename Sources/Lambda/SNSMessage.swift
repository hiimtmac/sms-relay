import Foundation
import Logging
import AWSLambdaEvents

struct SNSMessage: Codable {
    let originationNumber: String // +XXXXXXXXXXX - From (number that sent the message)
    let destinationNumber: String // +XXXXXXXXXXX - To (which which pinpoint long code)
    let messageBody: String // Text message body
}

extension SNSEvent {
    func snsMessage(logger: Logger) throws -> SNSMessage {
        guard let messagePayload = records.first?.sns.message else {
            logger.error("No message in payload: \(records)")
            throw LambdaError.missingMessage
        }
        
        let data = Data(messagePayload.utf8)
        return try JSONDecoder().decode(SNSMessage.self, from: data)
    }
}
