import Foundation

/// Substrate client settings
struct SubstrateClientSettings {
    var webSocketPath: String?
    var webSocketPort: Int?
    let runtimeMetadataUpdateTimeoutMs: Int64
    let namingPolicy: SubstrateClientNamingPolicy
    let objectStorageFactory: ObjectStorageFactory
    
    /// The default settings for substrate client
    static func `default`() -> SubstrateClientSettings {
        .init(
            runtimeMetadataUpdateTimeoutMs: 3600 * 1000,
            namingPolicy: .caseInsensitive,
            objectStorageFactory: InMemoryObjectStorageFactory()
        )
    }
}
