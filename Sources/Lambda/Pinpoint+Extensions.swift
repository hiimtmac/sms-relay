import SotoPinpoint

extension Pinpoint {
    func send(body: String, from: String, to: String) async throws -> Pinpoint.SendMessagesResponse {
        let appId = try env.get(.PINPOINT_APP_ID)
        
        let sms = Pinpoint.SendMessagesRequest(
            applicationId: appId,
            messageRequest: .init(
                addresses: [to: .init(channelType: .sms)],
                messageConfiguration: .init(
                    smsMessage: .init(
                        body: body,
                        messageType: .transactional,
                        originationNumber: from
                    )
                )
            )
        )
        
        return try await sendMessages(sms)
    }
}
