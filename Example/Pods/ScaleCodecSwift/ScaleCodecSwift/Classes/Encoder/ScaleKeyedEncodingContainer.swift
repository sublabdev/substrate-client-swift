import Foundation

final class ScaleKeyedEncodingContainer<K: CodingKey>: KeyedEncodingContainerProtocol, ScaleEncodingContainer {
    
    // MARK: - KeyedEncodingContainerProtocol
    
    typealias Key = K
    
    let codingPath: [CodingKey]
    let userInfo: [CodingUserInfoKey: Any]
    
    // MARK: - ScaleEncodingContainer
    
    private var keys: [K] = []
    private var containers: [ScaleEncodingContainer] = []
    private let adapterProvider: ScaleCodecAdapterProvider

    var data: Data {
        containers.reduce(Data()) { $0 + $1.data }
    }
    
    // MARK: - Init
    
    private let encoderProvider: ScaleEncoderProvider
    
    init(
        encoderProvider: ScaleEncoderProvider,
        adapterProvider: ScaleCodecAdapterProvider,
        codingPath: [CodingKey] = [],
        userInfo: [CodingUserInfoKey: Any] = [:]
    ) {
        self.encoderProvider = encoderProvider
        self.adapterProvider = adapterProvider
        self.codingPath = codingPath
        self.userInfo = userInfo
        
        encodeIndexIfNeeded()
    }
    
    // This method is used only for Enums
    private func encodeIndexIfNeeded() {
        guard let index = codingPath.first?.intValue else {
            return
        }
        
        do {
            try nestedSingleValueEncodingContainer().encode(UInt8(index))
        } catch {
            assertionFailure()
        }
    }
    
    // MARK: - Encoding
    
    private func encodeIfPresent<T>(_ value: T?, forKey key: K, encoder: (T) throws -> Void) throws {
        if let value = value {
            try nestedSingleValueEncodingContainer(forKey: key).encodeNotNil()
            try encoder(value)
        } else {
            try nestedSingleValueEncodingContainer(forKey: key).encodeNil()
        }
    }
    
    func encodeNil(forKey key: K) throws {
        try nestedSingleValueEncodingContainer(forKey: key).encodeNil()
    }
    
    func encode(_ value: Bool, forKey key: K) throws {
        try nestedSingleValueEncodingContainer(forKey: key).encode(value)
    }
    
    func encodeIfPresent(_ value: Bool?, forKey key: K) throws {
        try nestedSingleValueEncodingContainer(forKey: key).encode(value)
    }
    
    func encode(_ value: String, forKey key: K) throws {
        try nestedSingleValueEncodingContainer(forKey: key).encode(value)
    }
    
    func encodeIfPresent(_ value: String?, forKey key: K) throws {
        try encodeIfPresent(value, forKey: key) {
            try encode($0, forKey: key)
        }
    }
    
    func encode(_ value: Int, forKey key: K) throws {
        try nestedSingleValueEncodingContainer(forKey: key).encode(value)
    }
    
    func encodeIfPresent(_ value: Int?, forKey key: K) throws {
        try encodeIfPresent(value, forKey: key) {
            try encode($0, forKey: key)
        }
    }
    
    func encode(_ value: Int8, forKey key: K) throws {
        try nestedSingleValueEncodingContainer(forKey: key).encode(value)
    }
    
    func encodeIfPresent(_ value: Int8?, forKey key: K) throws {
        try encodeIfPresent(value, forKey: key) {
            try encode($0, forKey: key)
        }
    }
    
    func encode(_ value: Int16, forKey key: K) throws {
        try nestedSingleValueEncodingContainer(forKey: key).encode(value)
    }
    
    func encodeIfPresent(_ value: Int16?, forKey key: K) throws {
        try encodeIfPresent(value, forKey: key) {
            try encode($0, forKey: key)
        }
    }
    
    func encode(_ value: Int32, forKey key: K) throws {
        try nestedSingleValueEncodingContainer(forKey: key).encode(value)
    }
    
    func encodeIfPresent(_ value: Int32?, forKey key: K) throws {
        try encodeIfPresent(value, forKey: key) {
            try encode($0, forKey: key)
        }
    }
    
    func encode(_ value: Int64, forKey key: K) throws {
        try nestedSingleValueEncodingContainer(forKey: key).encode(value)
    }
    
    func encodeIfPresent(_ value: Int64?, forKey key: K) throws {
        try encodeIfPresent(value, forKey: key) {
            try encode($0, forKey: key)
        }
    }
    
    func encode(_ value: UInt, forKey key: K) throws {
        try nestedSingleValueEncodingContainer(forKey: key).encode(value)
    }
    
    func encodeIfPresent(_ value: UInt?, forKey key: K) throws {
        try encodeIfPresent(value, forKey: key) {
            try encode($0, forKey: key)
        }
    }
    
    func encode(_ value: UInt8, forKey key: K) throws {
        try nestedSingleValueEncodingContainer(forKey: key).encode(value)
    }
    
    func encodeIfPresent(_ value: UInt8?, forKey key: K) throws {
        try encodeIfPresent(value, forKey: key) {
            try encode($0, forKey: key)
        }
    }
    
    func encode(_ value: UInt16, forKey key: K) throws {
        try nestedSingleValueEncodingContainer(forKey: key).encode(value)
    }
    
    func encodeIfPresent(_ value: UInt16?, forKey key: K) throws {
        try encodeIfPresent(value, forKey: key) {
            try encode($0, forKey: key)
        }
    }
    
    func encode(_ value: UInt32, forKey key: K) throws {
        try nestedSingleValueEncodingContainer(forKey: key).encode(value)
    }
    
    func encodeIfPresent(_ value: UInt32?, forKey key: K) throws {
        try encodeIfPresent(value, forKey: key) {
            try encode($0, forKey: key)
        }
    }
    
    func encode(_ value: UInt64, forKey key: K) throws {
        try nestedSingleValueEncodingContainer(forKey: key).encode(value)
    }
    
    func encodeIfPresent(_ value: UInt64?, forKey key: K) throws {
        try encodeIfPresent(value, forKey: key) {
            try encode($0, forKey: key)
        }
    }
    
    func encode<T>(_ value: T, forKey key: K) throws where T : Encodable {
        try nestedSingleValueEncodingContainer(forKey: key).encode(value)
    }
    
    func encodeIfPresent<T>(_ value: T?, forKey key: K) throws where T : Encodable {
        try encodeIfPresent(value, forKey: key) {
            try encode($0, forKey: key)
        }
    }
    
    func encodeConditional<T>(_ object: T, forKey key: K) throws where T : AnyObject, T : Encodable {
        print("[encodeConditional]")
    }
    
    private func nestedCodingPath(forKey key: CodingKey? = nil) -> [CodingKey] {
        if let key = key {
            return codingPath + [key]
        }
         
        return codingPath
    }
    
    private func nestedSingleValueEncodingContainer(forKey key: K? = nil, append: Bool = true) -> ScaleSingleValueEncodingContainer {
        let container = ScaleSingleValueEncodingContainer(
            encoderProvider: encoderProvider,
            adapterProvider: adapterProvider,
            codingPath: nestedCodingPath(forKey: key),
            userInfo: userInfo
        )
        
        if append {
            containers.append(container)
        }
        
        return container
    }
    
    func nestedContainer<NestedKey>(
        keyedBy keyType: NestedKey.Type,
        forKey key: K
    ) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
        let container = ScaleKeyedEncodingContainer<NestedKey>(
            encoderProvider: encoderProvider,
            adapterProvider: adapterProvider,
            codingPath: nestedCodingPath(forKey: key),
            userInfo: userInfo
        )
        
        containers.append(container)
        return KeyedEncodingContainer(container)
    }
    
    func nestedUnkeyedContainer(forKey key: K) -> UnkeyedEncodingContainer {
        let container = ScaleUnkeyedEncodingContainer(
            encoderProvider: encoderProvider,
            adapterProvider: adapterProvider,
            codingPath: nestedCodingPath(forKey: key),
            userInfo: userInfo
        )
        
        containers.append(container)
        return container
    }
    
    func superEncoder() -> Encoder {
        encoderProvider.encoder(codingPath: codingPath, userInfo: userInfo)
    }
    
    func superEncoder(forKey key: K) -> Encoder {
        encoderProvider.encoder(codingPath: nestedCodingPath(forKey: key), userInfo: userInfo)
    }
}
