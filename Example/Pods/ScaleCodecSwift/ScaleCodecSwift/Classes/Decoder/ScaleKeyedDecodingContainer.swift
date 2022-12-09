import Foundation

final class ScaleKeyedDecodingContainer<K: CodingKey>: KeyedDecodingContainerProtocol {

    // MARK: - KeyedDecodingContainerProtocol
    
    typealias Key = K
    
    var codingPath: [CodingKey]
    let userInfo: [CodingUserInfoKey: Any]
    
    var allKeys: [K] = []
    
    func contains(_ key: K) -> Bool {
        allKeys.contains { $0.stringValue == key.stringValue && $0.intValue == key.intValue }
    }
    
    // MARK: - Init
    
    private let decoderProvider: ScaleDecoderProvider
    private let dataReader: DataReader
    private let adapterProvider: ScaleCodecAdapterProvider
    
    init(
        decoderProvider: ScaleDecoderProvider,
        dataReader: DataReader,
        adapterProvider: ScaleCodecAdapterProvider,
        codingPath: [CodingKey],
        userInfo: [CodingUserInfoKey: Any]
    ) {
        self.decoderProvider = decoderProvider
        self.dataReader = dataReader
        self.adapterProvider = adapterProvider
        self.codingPath = codingPath
        self.userInfo = userInfo
        
        tryDecodeIndex()
    }
    
    // Trying to decode an index which is used for getting a specific key
    private func tryDecodeIndex() {
        let currentOffset = dataReader.offset
        let index: UInt8
        
        do {
            index = try nestedSingleValueDecodingContainer().decode(UInt8.self)
        } catch {
            dataReader.offset = currentOffset
            return
        }
        
        guard let key = K(intValue: Int(index)) else {
            dataReader.offset = currentOffset
            return
        }
        
        allKeys = [key]
    }
    
    // MARK: - Decoding
    // Decodes generic optional values for a specified key
    private func decodeIfPresent<T>(_ type: T.Type, forKey key: K, decoder: () throws -> T) throws -> T? {
        let isPresent = try nestedSingleValueDecodingContainer(forKey: key).decode(Bool.self)
        return isPresent ? try decoder() : nil
    }
    // Decodes nil values for a specified key
    func decodeNil(forKey key: K) throws -> Bool {
        nestedSingleValueDecodingContainer(forKey: key).decodeNil()
    }
    // Decodes to Bool values for a specified key
    func decode(_ type: Bool.Type, forKey key: K) throws -> Bool {
        try nestedSingleValueDecodingContainer(forKey: key).read(type)
    }
    // Decodes to optional Bool values for a specified key
    func decodeIfPresent(_ type: Bool.Type, forKey key: K) throws -> Bool? {
        try nestedSingleValueDecodingContainer(forKey: key).read(Bool?.self)
    }
    // Decodes to String values for a specified key
    func decode(_ type: String.Type, forKey key: K) throws -> String {
        try nestedSingleValueDecodingContainer(forKey: key).read(type)
    }
    // Decodes to optional String values for a specified key
    func decodeIfPresent(_ type: String.Type, forKey key: K) throws -> String? {
        try decodeIfPresent(type, forKey: key) {
            try decode(type, forKey: key)
        }
    }
    // Decodes to Int values for a specified key
    func decode(_ type: Int.Type, forKey key: K) throws -> Int {
        try nestedSingleValueDecodingContainer(forKey: key).read(type)
    }
    // Decodes to optional Int values for a specified key
    func decodeIfPresent(_ type: Int.Type, forKey key: K) throws -> Int? {
        try decodeIfPresent(type, forKey: key) {
            try decode(type, forKey: key)
        }
    }
    // Decodes to Int8 values for a specified key
    func decode(_ type: Int8.Type, forKey key: K) throws -> Int8 {
        try nestedSingleValueDecodingContainer(forKey: key).read(type)
    }
    // Decodes to optional Int8 values for a specified key
    func decodeIfPresent(_ type: Int8.Type, forKey key: K) throws -> Int8? {
        try decodeIfPresent(type, forKey: key) {
            try decode(type, forKey: key)
        }
    }
    // Decodes to Int16 values for a specified key
    func decode(_ type: Int16.Type, forKey key: K) throws -> Int16 {
        try nestedSingleValueDecodingContainer(forKey: key).read(type)
    }
    // Decodes to optional Int16 values for a specified key
    func decodeIfPresent(_ type: Int16.Type, forKey key: K) throws -> Int16? {
        try decodeIfPresent(type, forKey: key) {
            try decode(type, forKey: key)
        }
    }
    // Decodes to Int32 values for a specified key
    func decode(_ type: Int32.Type, forKey key: K) throws -> Int32 {
        try nestedSingleValueDecodingContainer(forKey: key).read(type)
    }
    // Decodes to optional Int32 values for a specified key
    func decodeIfPresent(_ type: Int32.Type, forKey key: K) throws -> Int32? {
        try decodeIfPresent(type, forKey: key) {
            try decode(type, forKey: key)
        }
    }
    // Decodes to Int64 values for a specified key
    func decode(_ type: Int64.Type, forKey key: K) throws -> Int64 {
        try nestedSingleValueDecodingContainer(forKey: key).read(type)
    }
    // Decodes to optional Int64 values for a specified key
    func decodeIfPresent(_ type: Int64.Type, forKey key: K) throws -> Int64? {
        try decodeIfPresent(type, forKey: key) {
            try decode(type, forKey: key)
        }
    }
    // Decodes to UInt values for a specified key
    func decode(_ type: UInt.Type, forKey key: K) throws -> UInt {
        try nestedSingleValueDecodingContainer(forKey: key).read(type)
    }
    // Decodets to optional UInt values for a specified key
    func decodeIfPresent(_ type: UInt.Type, forKey key: K) throws -> UInt? {
        try decodeIfPresent(type, forKey: key) {
            try decode(type, forKey: key)
        }
    }
    // Decodets to UInt8 values for a specified key
    func decode(_ type: UInt8.Type, forKey key: K) throws -> UInt8 {
        try nestedSingleValueDecodingContainer(forKey: key).read(type)
    }
    // Decodets to optional UInt8 values for a specified key
    func decodeIfPresent(_ type: UInt8.Type, forKey key: K) throws -> UInt8? {
        try decodeIfPresent(type, forKey: key) {
            try decode(type, forKey: key)
        }
    }
    // Decodets to UInt16 values for a specified key
    func decode(_ type: UInt16.Type, forKey key: K) throws -> UInt16 {
        try nestedSingleValueDecodingContainer(forKey: key).read(type)
    }
    // Decodets to optional UInt16 values for a specified key
    func decodeIfPresent(_ type: UInt16.Type, forKey key: K) throws -> UInt16? {
        try decodeIfPresent(type, forKey: key) {
            try decode(type, forKey: key)
        }
    }
    // Decodets to UInt32 values for a specified key
    func decode(_ type: UInt32.Type, forKey key: K) throws -> UInt32 {
        try nestedSingleValueDecodingContainer(forKey: key).read(type)
    }
    // Decodets to optional UInt32 values for a specified key
    func decodeIfPresent(_ type: UInt32.Type, forKey key: K) throws -> UInt32? {
        try decodeIfPresent(type, forKey: key) {
            try decode(type, forKey: key)
        }
    }
    // Decodets to UInt64 values for a specified key
    func decode(_ type: UInt64.Type, forKey key: K) throws -> UInt64 {
        try nestedSingleValueDecodingContainer(forKey: key).read(type)
    }
    // Decodets to optional UInt64 values for a specified key
    func decodeIfPresent(_ type: UInt64.Type, forKey key: K) throws -> UInt64? {
        try decodeIfPresent(type, forKey: key) {
            try decode(type, forKey: key)
        }
    }
    // Decodets to generict T values for a specified key
    func decode<T>(_ type: T.Type, forKey key: K) throws -> T where T : Decodable {
        try nestedSingleValueDecodingContainer(forKey: key).read(type)
    }
    // Decodes to optional T values for a specified key
    func decodeIfPresent<T>(_ type: T.Type, forKey key: K) throws -> T? where T : Decodable {
        try decodeIfPresent(type, forKey: key) {
            try decode(type, forKey: key)
        }
    }
    
    private func nestedCodingPath(forKey key: CodingKey? = nil) -> [CodingKey] {
        if let key = key {
            return codingPath + [key]
        }
         
        return codingPath
    }
    // Provides a nested scale single value decoding container
    private func nestedSingleValueDecodingContainer(forKey key: K? = nil) -> ScaleSingleValueDecodingContainer {
        ScaleSingleValueDecodingContainer(
            decoderProvider: decoderProvider,
            dataReader: dataReader,
            adapterProvider: adapterProvider,
            codingPath: nestedCodingPath(forKey: key),
            userInfo: userInfo
        )
    }
    // Provides a nested scale keyed decoding container
    func nestedContainer<NestedKey>(
        keyedBy type: NestedKey.Type,
        forKey key: K
    ) throws -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey {
        let container = ScaleKeyedDecodingContainer<NestedKey>(
            decoderProvider: decoderProvider,
            dataReader: dataReader,
            adapterProvider: adapterProvider,
            codingPath: codingPath,
            userInfo: userInfo
        )
        return KeyedDecodingContainer(container)
    }
    // Provides a nested scale unkeyed decoding container
    func nestedUnkeyedContainer(forKey key: K) throws -> UnkeyedDecodingContainer {
        try ScaleUnkeyedDecodingContainer(
            decoderProvider: decoderProvider,
            dataReader: dataReader,
            adapterProvider: adapterProvider,
            codingPath: codingPath,
            userInfo: userInfo
        )
    }

    func superDecoder() throws -> Decoder {
        decoderProvider.decoder(
            dataReader: dataReader,
            adapterProvider: adapterProvider,
            codingPath: codingPath,
            userInfo: userInfo
        )
    }

    func superDecoder(forKey key: K) throws -> Decoder {
        decoderProvider.decoder(
            dataReader: dataReader,
            adapterProvider: adapterProvider,
            codingPath: nestedCodingPath(forKey: key),
            userInfo: userInfo
        )
    }
}
