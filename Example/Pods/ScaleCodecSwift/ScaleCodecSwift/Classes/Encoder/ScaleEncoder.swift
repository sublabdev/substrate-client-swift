import Foundation

/// A default interface for providing encoding functionality
protocol ScaleEncoding {
    /// Encodes value of type `T` to Data
    /// - Parameters:
    ///     - value: A value of type `T` that needs to be encoded
    /// - Returns: An encoded Data
    func encode<T>(_ value: T) throws -> Data where T : Encodable
}

/// An interface that contains Data that needs to be encoded
protocol ScaleEncodingContainer {
    var data: Data { get }
}

/// An interface for encoder provider
protocol ScaleEncoderProvider {
    /// Provides an encoder
    /// - Parameters:
    ///     - codingPath: An array of `CodingKey` objects
    ///     - userInfo: A dict containing user-defined `CodingUserInfoKey` as keys
    /// - Returns: An encoder container
    func encoder(
        codingPath: [CodingKey],
        userInfo: [CodingUserInfoKey: Any]
    ) -> Encoder & ScaleEncodingContainer
}

extension ScaleEncoderProvider {
    // A default implementation of the protocol's method
    func encoder(codingPath: [CodingKey]) -> Encoder & ScaleEncodingContainer{
        encoder(codingPath: codingPath, userInfo: [:])
    }
    
    // Encoding without coding paths
    func encoder(userInfo: [CodingUserInfoKey: Any]) -> Encoder & ScaleEncodingContainer {
        encoder(codingPath: [], userInfo: userInfo)
    }
    
    // Encoding without coding paths and user info
    func encoder() -> Encoder & ScaleEncodingContainer {
        encoder(codingPath: [], userInfo: [:])
    }
}

// MARK: - Encoding, ScaleEncoderProvider
/// Handles scale encoding
public final class ScaleEncoder: ScaleEncoding, ScaleEncoderProvider {
    private let codingPath: [CodingKey]
    private let userInfo: [CodingUserInfoKey: Any]
    private let adapterProvider: ScaleCodecAdapterProvider

    /// Creates a scale encoder
    /// - Parameters:
    ///     - adapterProvider: An object that provides adapters based on a type being encoded
    ///     - codingPath: An array of `CodingKey` objects
    ///     - userInfo: A dict containing user-defined `CodingUserInfoKey` as keys
    public init(
        adapterProvider: ScaleCodecAdapterProvider,
        codingPath: [CodingKey] = [],
        userInfo: [CodingUserInfoKey: Any] = [:]
    ) {
        self.adapterProvider = adapterProvider
        self.codingPath = codingPath
        self.userInfo = userInfo
    }

    /// Initializes `ScaleEncoderContainer` which provides a specific container (keyed, unkeyed and single value) based on a type that needs to be encoded
    ///  - Parameters:
    ///     - codingPath: An array of `CodingKey` objects
    ///     - userInfo: A dict containing user-defined
    ///  - Returns: `ScaleEncoderContainer`
    func encoder(
        codingPath: [CodingKey],
        userInfo: [CodingUserInfoKey: Any]
    ) -> Encoder & ScaleEncodingContainer {
        ScaleEncoderContainer(
            provider: self,
            adapterProvider: adapterProvider,
            codingPath: codingPath,
            userInfo: userInfo
        )
    }

    /// Encodes a generic type `T`
    /// - Parameters:
    ///     - value: A value of a generic type `T`. T should conform to `Encodable` protocol
    /// - Returns: Encoded `Data`
    public func encode<T: Encodable>(_ value: T) throws -> Data {
        if let data = try? adapterProvider.adapter(for: T.self).write(value: value) {
            // Types like Ints, Strings etc will be resolved via their custom adapters
            // Types with custom optional adapters will be resolved here as well (the main cause of this 'if' condition)
            // Other types will be resolved via GenericAdapter though types like array and all other optionals will be resolved
            // via their custom adapters
            // Struct, Enums will throw 'No adapter found' error thus should be resolved via basic containers
            return data
        }
        
        let encoder = encoder()

        try value.encode(to: encoder)
        return encoder.data
    }
}

// MARK: - ScaleEncoderContainer
private final class ScaleEncoderContainer: Encoder, ScaleEncodingContainer {
    var codingPath: [CodingKey]
    var userInfo: [CodingUserInfoKey: Any]
    
    private let provider: ScaleEncoderProvider
    private var container: ScaleEncodingContainer?
    private let adapterProvider: ScaleCodecAdapterProvider
    
    fileprivate var data: Data {
        container?.data ?? Data()
    }
    
    fileprivate init(
        provider: ScaleEncoderProvider,
        adapterProvider: ScaleCodecAdapterProvider,
        codingPath: [CodingKey] = [],
        userInfo: [CodingUserInfoKey: Any] = [:]) {
            self.provider = provider
            self.adapterProvider = adapterProvider
            self.codingPath = codingPath
            self.userInfo = userInfo
        }
    
    // Returns a keyed encoding container
    func container<Key>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> where Key : CodingKey {
        let container = ScaleKeyedEncodingContainer<Key>(
            encoderProvider: provider,
            adapterProvider: adapterProvider,
            codingPath: codingPath,
            userInfo: userInfo
        )
        
        self.container = container
        return KeyedEncodingContainer(container)
    }
    
    // Returns an unkeyed encoding container
    func unkeyedContainer() -> UnkeyedEncodingContainer {
        let container = ScaleUnkeyedEncodingContainer(
            encoderProvider: provider,
            adapterProvider: adapterProvider,
            codingPath: codingPath,
            userInfo: userInfo
        )
        
        self.container = container
        return container
    }
    
    // Returns a single value encoding container
    func singleValueContainer() -> SingleValueEncodingContainer {
        let container = ScaleSingleValueEncodingContainer(
            encoderProvider: provider,
            adapterProvider: adapterProvider,
            codingPath: codingPath,
            userInfo: userInfo
        )
        
        self.container = container
        return container
    }
}
