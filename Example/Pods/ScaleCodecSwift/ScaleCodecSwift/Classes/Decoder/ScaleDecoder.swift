import Foundation

/// An interface for encoder provider
protocol ScaleDecoderProvider {
    /// Provides an encoder
    /// - Parameters:
    ///     - dataReader: A `DataReader` that holds and reads the `Data`
    ///     - adapterProvider: An object that provides adapters to handle read and write opertations
    ///     - codingPath: An array of `CodingKey` objects
    ///     - userInfo: A dict containing user-defined `CodingUserInfoKey` as keys
    /// - Returns: A decoder container
    func decoder(
        dataReader: DataReader,
        adapterProvider: ScaleCodecAdapterProvider,
        codingPath: [CodingKey],
        userInfo: [CodingUserInfoKey: Any]
    ) -> Decoder
}

/// A default interface for providing decoding functionality
protocol ScaleDecoding {
    func decode<T>(_ type: T.Type, from reader: DataReader) throws -> T where T : Decodable
}

// MARK: - Decoding, ScaleDecoderProvider
/// Handles scale decoding
public final class ScaleDecoder: ScaleDecoding, ScaleDecoderProvider {
    private let codingPath: [CodingKey]
    private let userInfo: [CodingUserInfoKey: Any]
    private let adapterProvider: ScaleCodecAdapterProvider
    
    /// Creates a scale decoder
    /// - Parameters:
    ///     - adapterProvider: An object that provides adapters based on a type being decoded
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

    /// Decodes a generic type `T` from provided `Data`
    /// - Parameters:
    ///     - type: A type to which provided `Data` should be decoded
    ///     - data: The data that needs to be decoded into a type
    /// - Returns: A decoded type
    public func decode<T: Decodable>(_ type: T.Type, from data: Data) throws -> T {
        try decode(type, from: DataReader(data: data))
    }
    
    func decode<T: Decodable>(_ type: T.Type, from dataReader: DataReader) throws -> T {
        let currentOffset = dataReader.offset
        
        do {
            // Types like Ints, Strings etc will be resolved via their custom adapters
            // Types with custom optional adapters will be resolved here as well (the main cause of this 'if' condition)
            // Other types will be resolved via GenericAdapter though types like array and all other optionals will be resolved
            // via their custom adapters
            // Struct, Enums will throw 'No adapter found' error thus should be resolved via basic containers
            return try adapterProvider.adapter(for: type).read(type, from: dataReader)
        } catch ScaleCodecAdapterProvider.Error.noAdapterFound {
            // No adapter found hence resolving via the default way
        } catch let error {
            throw error
        }
        
        dataReader.offset = currentOffset
        
        let decoder = decoder(
            dataReader: dataReader,
            adapterProvider: adapterProvider,
            codingPath: codingPath,
            userInfo: userInfo
        )
        
        return try T(from: decoder)
    }
    
    /// Initializes `ScaleDecoderContainer` which provides a specific container (keyed, unkeyed and single value) based on a type that needs to be decoded
    ///  - Parameters:
    ///     - codingPath: An array of `CodingKey` objects
    ///     - userInfo: A dict containing user-defined
    ///  - Returns: `ScaleDecoderContainer` object
    func decoder(
        dataReader: DataReader,
        adapterProvider: ScaleCodecAdapterProvider,
        codingPath: [CodingKey],
        userInfo: [CodingUserInfoKey: Any]
    ) -> Decoder {
        ScaleDecoderContainer(
            decoderProvider: self,
            dataReader: dataReader,
            adapterProvider: adapterProvider,
            codingPath: codingPath,
            userInfo: userInfo
        )
    }
}

// Handles containers for decoding
private final class ScaleDecoderContainer: Decoder {

    var codingPath: [CodingKey]
    var userInfo: [CodingUserInfoKey : Any]

    private let decoderProvider: ScaleDecoderProvider
    private let dataReader: DataReader
    private let adapterProvider: ScaleCodecAdapterProvider
    
    init(
        decoderProvider: ScaleDecoderProvider,
        dataReader: DataReader,
        adapterProvider: ScaleCodecAdapterProvider,
        codingPath: [CodingKey] = [],
        userInfo: [CodingUserInfoKey: Any] = [:]
    ) {
        self.decoderProvider = decoderProvider
        self.dataReader = dataReader
        self.adapterProvider = adapterProvider
        self.codingPath = codingPath
        self.userInfo = userInfo
    }

    // Returns a single value decoding container
    func singleValueContainer() throws -> SingleValueDecodingContainer {
        ScaleSingleValueDecodingContainer(
            decoderProvider: decoderProvider,
            dataReader: dataReader,
            adapterProvider: adapterProvider,
            codingPath: codingPath,
            userInfo: userInfo
        )
    }

    // Returns an unkeyed decoding container
    func unkeyedContainer() throws -> UnkeyedDecodingContainer {
        try ScaleUnkeyedDecodingContainer(
            decoderProvider: decoderProvider,
            dataReader: dataReader,
            adapterProvider: adapterProvider,
            codingPath: codingPath,
            userInfo: userInfo
        )
    }

    // Returns a keyed decoding container
    func container<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> where Key : CodingKey {
        let container = ScaleKeyedDecodingContainer<Key>(
            decoderProvider: decoderProvider,
            dataReader: dataReader,
            adapterProvider: adapterProvider,
            codingPath: codingPath,
            userInfo: userInfo
        )
        
        return KeyedDecodingContainer(container)
    }
}
