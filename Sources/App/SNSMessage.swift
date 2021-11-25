import Foundation

struct SNSMessage: Codable {
    let originationNumber: String // +XXXXXXXXXXX - From (number that sent the message)
    let destinationNumber: String // +XXXXXXXXXXX - To (which which pinpoint long code)
    let messageBody: String // Text message body
}
