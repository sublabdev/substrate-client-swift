import Foundation

/// Substrate client settings
struct SubstrateClientSettings {
    var webSocketPath: String?
    var webSocketPort: Int?
    let runtimeMetadataUpdateTimeoutMs: Int64
    let namingPolicy: SubstrateClientNamingPolicy
    let clientQueue: DispatchQueue
    let innerQueue = DispatchQueue(
        label: "substrate-client-inner-queue",
        qos: .userInitiated,
        attributes: .concurrent
    )
    
    /// The default settings for substrate client
    /// - Returns: Settings for `SubstrateClient`
    static func `default`() -> SubstrateClientSettings {
        self.default(clientQueue: .main)
    }
    
    /// The default settings for substrate client with a custom client queue
    /// - Parameters:
    ///     - clientQueue: A custom client queue on which the results will be returned
    /// - Returns: Settings for `SubstrateClient`
    static func `default`(clientQueue: DispatchQueue) -> SubstrateClientSettings {
        .init(
            runtimeMetadataUpdateTimeoutMs: 3600 * 1000,
            namingPolicy: .caseInsensitive,
            clientQueue: clientQueue
        )
    }
}
