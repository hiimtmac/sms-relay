import AWSLambdaEvents
import AWSLambdaRuntime
import SotoPinpoint

let client = AWSClient()
let pinpoint = Pinpoint(
    client: client,
    region: .cacentral1
)

func handler(_ event: SNSEvent, context: LambdaContext) async throws {
    let ownerNumber = try env.get(.OWNER_NUMBER)
    let relayNumber = try env.get(.RELAY_NUMBER)
    
    let message = try event.snsMessage(logger: context.logger)
    
    let body: String
    let from: String
    let to: String
    
    if message.originationNumber == ownerNumber {
        let components = message.messageBody.components(separatedBy: "\n")
        
        if
            components.count >= 2,
            let numbers = try? components[0].numbers(),
            numbers.count == 1,
            let number = numbers.first
        {
            body = components
                .dropFirst()
                .joined(separator: "\n")
                .trimmingCharacters(in: .whitespacesAndNewlines)

            from = relayNumber
            to = number
        } else {
            body = """
            Relayed: \(message.originationNumber):
            \(message.messageBody)
            """
            
            from = relayNumber
            to = ownerNumber
        }
    } else {
        body = """
        Relayed: \(message.originationNumber):
        \(message.messageBody)
        """
        
        from = relayNumber
        to = ownerNumber
    }
    
    let response = try await pinpoint.send(
        body: body,
        from: from,
        to: to
    )
    
    guard
        response.messageResponse?.result?.count == 1,
        let result = response.messageResponse?.result?.first?.value
    else {
        context.logger.error("Bad Pinpoint Response")
        throw LambdaError.badResponse
    }
    
    guard result.deliveryStatus?.description == "SUCCESSFUL" else {
        let status = result.deliveryStatus?.description ?? "unknown"
        let message = result.statusMessage ?? "no message"
        
        context.logger.error("\(status): \(message)")
        throw LambdaError.unsuccessful("\(status): \(message)")
    }
}

let runtime = LambdaRuntime.init(body: handler)
try await runtime.run()
try await client.shutdown()
