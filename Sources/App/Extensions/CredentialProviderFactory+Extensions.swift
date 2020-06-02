import SotoCore

extension CredentialProviderFactory {
    static var enviro: Self {
        .static(
            accessKeyId: env[.RELAY_AWS_ACCESS_KEY_ID],
            secretAccessKey: env[.RELAY_AWS_SECRET_ACCESS_KEY]
        )
    }
}
