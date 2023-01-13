import Foundation

/// Substrate client settings
public struct SubstrateClientSettings {
    public var rpcPath: String?
    public var rpcParams: [String: String?]
    public var webSocketPath: String?
    public var webSocketPort: Int?
    public var webSocketParams: [String: String?]
    public var webSocketSecure: Bool
    public let runtimeMetadataUpdateTimeoutMs: Int64
    public let namingPolicy: SubstrateClientNamingPolicy
    // TODO: object storage
    public let clientQueue: DispatchQueue
    public let innerQueue = DispatchQueue(
        label: "substrate-client-inner-queue",
        qos: .userInitiated,
        attributes: .concurrent
    )
    
    public init(
        rpcPath: String? = nil,
        rpcParams: [String : String?],
        webSocketPath: String? = nil,
        webSocketPort: Int? = nil,
        webSocketParams: [String : String?],
        webSocketSecure: Bool,
        runtimeMetadataUpdateTimeoutMs: Int64,
        namingPolicy: SubstrateClientNamingPolicy,
        clientQueue: DispatchQueue
    ) {
        self.rpcPath = rpcPath
        self.rpcParams = rpcParams
        self.webSocketPath = webSocketPath
        self.webSocketPort = webSocketPort
        self.webSocketParams = webSocketParams
        self.webSocketSecure = webSocketSecure
        self.runtimeMetadataUpdateTimeoutMs = runtimeMetadataUpdateTimeoutMs
        self.namingPolicy = namingPolicy
        self.clientQueue = clientQueue
    }
    
    /// The default settings for substrate client
    /// - Returns: Settings for `SubstrateClient`
    public static func `default`() -> SubstrateClientSettings {
        self.default(clientQueue: .main)
    }
    
    /// The default settings for substrate client with a custom client queue
    /// - Parameters:
    ///     - clientQueue: A custom client queue on which the results will be returned
    /// - Returns: Settings for `SubstrateClient`
    public static func `default`(clientQueue: DispatchQueue) -> SubstrateClientSettings {
        .init(
            rpcParams: [:],
            webSocketParams: [:],
            webSocketSecure: false,
            runtimeMetadataUpdateTimeoutMs: 3600 * 1000,
            namingPolicy: .caseInsensitive,
            clientQueue: clientQueue
        )
    }
}
