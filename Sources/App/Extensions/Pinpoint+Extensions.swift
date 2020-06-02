import SotoPinpoint

extension Pinpoint {
    func send(message: SNSMessage) -> EventLoopFuture<Pinpoint.SendMessagesResponse> {
        let body = """
        Relayed: \(message.originationNumber):
        \(message.messageBody)
        """
        
        let sms = Pinpoint.SendMessagesRequest(
            applicationId: env[.RELAY_PINPOINT_APPLICATION_ID],
            messageRequest: .init(
                addresses: [env[.RELAY_DESTINATION_NUMBER]: .init(channelType: .sms)],
                messageConfiguration: .init(
                    sMSMessage: .init(
                        body: body,
                        messageType: .transactional,
                        originationNumber: message.destinationNumber
                    )
                )
            )
        )
        
        return sendMessages(sms)
    }
}
