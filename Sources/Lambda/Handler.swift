import AWSLambdaEvents
import AWSLambdaRuntime
import Configuration
import Logging
import ServiceLifecycle
import SotoPinpointSMSVoiceV2

@main
struct LambdaFunction {
    let aws: AWSClient
    let pinpointV2: PinpointSMSVoiceV2
    let config: ConfigReader
    let logger: Logger
    
    private init() async throws {
        var logger = Logger(label: "sns-relay")
        logger.logLevel = Lambda.env("LOG_LEVEL").flatMap(Logger.Level.init) ?? .info
                
        let aws = AWSClient()
        let pinpointV2 = PinpointSMSVoiceV2(client: aws, region: .cacentral1)
        
        let env = EnvironmentVariablesProvider()
        let config = ConfigReader(provider: env)
        
        self.aws = aws
        self.pinpointV2 = pinpointV2
        self.config = config
        self.logger = logger
    }
    
    private func start() async throws {
        let lambdaRuntime = LambdaRuntime(logger: self.logger, body: self.handler)
        let serviceGroup = ServiceGroup(
            services: [aws, lambdaRuntime],
            gracefulShutdownSignals: [.sigterm],
            cancellationSignals: [.sigint],
            logger: self.logger
        )
        
        try await serviceGroup.run()
    }

    func handler(_ event: SNSEvent, context: LambdaContext) async throws {
        let ownerNumber = try config.requiredString(forKey: "OWNER_NUMBER")
        let relayNumber = try config.requiredString(forKey: "RELAY_NUMBER")
        
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
        
        let _ = try await pinpointV2.sendTextMessage(
            PinpointSMSVoiceV2.SendTextMessageRequest(
                destinationPhoneNumber: to,
                maxPrice: "0.1",
                messageBody: body,
                messageType: .transactional,
                originationIdentity: from
            ),
            logger: context.logger
        )
    }

    static func main() async throws {
        try await LambdaFunction().start()
    }
}
