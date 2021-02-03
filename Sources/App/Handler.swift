import AWSLambdaEvents
import AWSLambdaRuntime
import NIO
import Foundation
import SotoPinpoint

public struct SMSLambdaHandler: EventLoopLambdaHandler {
    public typealias In = SNS.Event
    public typealias Out = Void
    
    let awsClient: AWSClient

    public init(context: Lambda.InitializationContext) {
        self.awsClient = AWSClient(
            credentialProvider: .enviro,
            httpClientProvider: .createNewWithEventLoopGroup(context.eventLoop),
            logger: context.logger
        )
    }
    
    public func handle(context: Lambda.Context, event: SNS.Event) -> EventLoopFuture<Void> {
        let pinpoint = Pinpoint(
            client: awsClient,
            region: .cacentral1
        )
        
        return context.eventLoop.submit {
            guard let messagePayload = event.records.first?.sns.message else {
                context.logger.error("No message in payload: \(event.records)")
                throw Error.missingMessage
            }
            
            let data = Data(messagePayload.utf8)
            return try JSONDecoder().decode(SNSMessage.self, from: data)
        }
        .flatMap(pinpoint.send)
        .flatMapThrowing { response in
            guard
                response.messageResponse.result?.count == 1,
                let result = response.messageResponse.result?.first?.value
            else {
                context.logger.error("Bad Pinpoint Response")
                throw Error.badResponse
            }
            
            guard result.deliveryStatus.description == "SUCCESSFUL" else {
                let status = result.deliveryStatus.description
                let message = result.statusMessage ?? "no message"
                
                context.logger.error("\(status): \(message)")
                throw Error.unsuccessful(message: "\(status): \(message)")
            }
        }
    }
    
    public func shutdown(context: Lambda.ShutdownContext) -> EventLoopFuture<Void> {
        let promise = context.eventLoop.makePromise(of: Void.self)
        awsClient.shutdown() { error in
            if let error = error {
                promise.fail(error)
            } else {
                promise.succeed(())
            }
        }
        return promise.futureResult
    }
}
