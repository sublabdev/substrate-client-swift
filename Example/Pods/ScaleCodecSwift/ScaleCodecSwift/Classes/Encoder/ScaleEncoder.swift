import Foundation

protocol ScaleEncoding {
    func encode<T>(_ value: T) throws -> Data where T : Encodable
}

protocol ScaleEncodingContainer {
    var data: Data { get }
}

protocol ScaleEncoderProvider {
    func encoder(
        codingPath: [CodingKey],
        userInfo: [CodingUserInfoKey: Any]
    ) -> Encoder & ScaleEncodingContainer
}

extension ScaleEncoderProvider {
    func encoder(codingPath: [CodingKey]) -> Encoder & ScaleEncodingContainer{
        encoder(codingPath: codingPath, userInfo: [:])
    }
    
    func encoder(userInfo: [CodingUserInfoKey: Any]) -> Encoder & ScaleEncodingContainer {
        encoder(codingPath: [], userInfo: userInfo)
    }
    
    func encoder() -> Encoder & ScaleEncodingContainer {
        encoder(codingPath: [], userInfo: [:])
    }
}

// MARK: - Encoding, ScaleEncoderProvider

public final class ScaleEncoder: ScaleEncoding, ScaleEncoderProvider {
    private let codingPath: [CodingKey]
    private let userInfo: [CodingUserInfoKey: Any]
    private let adapterProvider: ScaleCodecAdapterProvider

    public init(
        adapterProvider: ScaleCodecAdapterProvider,
        codingPath: [CodingKey] = [],
        userInfo: [CodingUserInfoKey: Any] = [:]
    ) {
        self.adapterProvider = adapterProvider
        self.codingPath = codingPath
        self.userInfo = userInfo
    }

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

    public func encode<T>(_ value: T) throws -> Data where T : Encodable {
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
