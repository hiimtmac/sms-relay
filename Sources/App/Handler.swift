import AWSLambdaEvents
import AWSLambdaRuntime
import NIO
import Foundation
import SotoPinpoint

public struct SMSLambdaHandler: AsyncLambdaHandler {
    public typealias In = SNS.Event
    public typealias Out = Void
    
    let pinpoint: Pinpoint

    public init(context: Lambda.InitializationContext) {        
        let awsClient = AWSClient(
            credentialProvider: .environment,
            httpClientProvider: .createNewWithEventLoopGroup(context.eventLoop),
            logger: context.logger
        )
        
        self.pinpoint = Pinpoint(
            client: awsClient,
            region: .cacentral1,
            byteBufferAllocator: context.allocator
        )
    }
    
    public func handle(event: SNS.Event, context: Lambda.Context) async throws {
        let ownerNumber = try env.get(.OWNER_NUMBER)
        let relayNumber = try env.get(.RELAY_NUMBER)
        
        guard let messagePayload = event.records.first?.sns.message else {
            context.logger.error("No message in payload: \(event.records)")
            throw LambdaError.missingMessage
        }
        
        let data = Data(messagePayload.utf8)
        let message = try JSONDecoder().decode(SNSMessage.self, from: data)
        
        let response: Pinpoint.SendMessagesResponse
        
        if message.originationNumber == ownerNumber {
            let components = message.messageBody.components(separatedBy: "\n")
            
            if
                components.count >= 2,
                let numbers = try? components[0].numbers(),
                numbers.count == 1,
                let number = numbers.first
            {
                let body = components
                    .dropFirst()
                    .joined(separator: "\n")
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                response = try await pinpoint.send(
                    body: body,
                    from: relayNumber,
                    to: number
                )
            } else {
                let body = """
                Relayed: \(message.originationNumber):
                \(message.messageBody)
                """
                
                response = try await pinpoint.send(
                    body: body,
                    from: relayNumber,
                    to: ownerNumber
                )
            }
        } else {
            let body = """
            Relayed: \(message.originationNumber):
            \(message.messageBody)
            """
            
            response = try await pinpoint.send(
                body: body,
                from: relayNumber,
                to: ownerNumber
            )
        }
        
        guard
            response.messageResponse.result?.count == 1,
            let result = response.messageResponse.result?.first?.value
        else {
            context.logger.error("Bad Pinpoint Response")
            throw LambdaError.badResponse
        }
        
        guard result.deliveryStatus.description == "SUCCESSFUL" else {
            let status = result.deliveryStatus.description
            let message = result.statusMessage ?? "no message"
            
            context.logger.error("\(status): \(message)")
            throw LambdaError.unsuccessful("\(status): \(message)")
        }
    }
    
    public func shutdown(context: Lambda.ShutdownContext) -> EventLoopFuture<Void> {
        let promise = context.eventLoop.makePromise(of: Void.self)
        pinpoint.client.shutdown() { error in
            if let error = error {
                promise.fail(error)
            } else {
                promise.succeed(())
            }
        }
        return promise.futureResult
    }
}
