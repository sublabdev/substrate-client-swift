import Foundation

protocol ScaleDecoderProvider {
    func decoder(
        dataReader: DataReader,
        adapterProvider: ScaleCodecAdapterProvider,
        codingPath: [CodingKey],
        userInfo: [CodingUserInfoKey: Any]
    ) -> Decoder
}

protocol ScaleDecoding {
    func decode<T>(_ type: T.Type, from reader: DataReader) throws -> T where T : Decodable
}

public final class ScaleDecoder: ScaleDecoding, ScaleDecoderProvider {
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

    public func decode<T>(_ type: T.Type, from data: Data) throws -> T where T : Decodable {
        try decode(type, from: DataReader(data: data))
    }
    
    func decode<T>(_ type: T.Type, from dataReader: DataReader) throws -> T where T : Decodable {
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

    func singleValueContainer() throws -> SingleValueDecodingContainer {
        ScaleSingleValueDecodingContainer(
            decoderProvider: decoderProvider,
            dataReader: dataReader,
            adapterProvider: adapterProvider,
            codingPath: codingPath,
            userInfo: userInfo
        )
    }

    func unkeyedContainer() throws -> UnkeyedDecodingContainer {
        try ScaleUnkeyedDecodingContainer(
            decoderProvider: decoderProvider,
            dataReader: dataReader,
            adapterProvider: adapterProvider,
            codingPath: codingPath,
            userInfo: userInfo
        )
    }

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
