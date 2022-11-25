import Foundation

final class ScaleUnkeyedEncodingContainer: UnkeyedEncodingContainer, ScaleEncodingContainer {
    
    // MARK: - UnkeyedEncodingContainer
    
    let codingPath: [CodingKey]
    let userInfo: [CodingUserInfoKey: Any]
    
    var count: Int { containers.count}
    
    // MARK: - ScaleEncodingContainer
    
    private var containers: [ScaleEncodingContainer] = []
    
    var data: Data {
        containers.reduce(Data()) { $0 + $1.data }
    }
    
    // MARK: - Init
    
    private let encoderProvider: ScaleEncoderProvider
    private let adapterProvider: ScaleCodecAdapterProvider
    
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
    }
    
    // MARK: - Encoding
    
    func encodeNil() throws {
        try nestedSingleValueEncodingContainer().encodeNil()
    }
    
    func encode(_ value: Bool) throws {
        try nestedSingleValueEncodingContainer().encode(value)
    }
    
    func encode(_ value: String) throws {
        try nestedSingleValueEncodingContainer().encode(value)
    }
    
    func encode(_ value: Int) throws {
        try nestedSingleValueEncodingContainer().encode(value)
    }
    
    func encode(_ value: Int8) throws {
        try nestedSingleValueEncodingContainer().encode(value)
    }
    
    func encode(_ value: Int16) throws {
        try nestedSingleValueEncodingContainer().encode(value)
    }
    
    func encode(_ value: Int32) throws {
        try nestedSingleValueEncodingContainer().encode(value)
    }
    
    func encode(_ value: Int64) throws {
        try nestedSingleValueEncodingContainer().encode(value)
    }
    
    func encode(_ value: UInt) throws {
        try nestedSingleValueEncodingContainer().encode(value)
    }
    
    func encode(_ value: UInt8) throws {
        try nestedSingleValueEncodingContainer().encode(value)
    }
    
    func encode(_ value: UInt16) throws {
        try nestedSingleValueEncodingContainer().encode(value)
    }
    
    func encode(_ value: UInt32) throws {
        try nestedSingleValueEncodingContainer().encode(value)
    }
    
    func encode(_ value: UInt64) throws {
        try nestedSingleValueEncodingContainer().encode(value)
    }
    
    func encode<T>(_ value: T) throws where T : Encodable {
        try nestedSingleValueEncodingContainer().encode(value)
    }
    
    private func nestedSingleValueEncodingContainer() throws -> ScaleSingleValueEncodingContainer {
        let container = ScaleSingleValueEncodingContainer(
            encoderProvider: encoderProvider,
            adapterProvider: adapterProvider,
            codingPath: codingPath,
            userInfo: userInfo
        )
        
        containers.append(container)
        return container
    }
    
    func nestedContainer<NestedKey>(
        keyedBy keyType: NestedKey.Type
    ) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
        KeyedEncodingContainer(ScaleKeyedEncodingContainer(
            encoderProvider: encoderProvider,
            adapterProvider: adapterProvider,
            codingPath: codingPath,
            userInfo: userInfo)
        )
    }
    
    func nestedUnkeyedContainer() -> UnkeyedEncodingContainer {
        ScaleUnkeyedEncodingContainer(
            encoderProvider: encoderProvider,
            adapterProvider: adapterProvider,
            codingPath: codingPath,
            userInfo: userInfo
        )
    }
    
    func superEncoder() -> Encoder {
        encoderProvider.encoder(codingPath: codingPath, userInfo: userInfo)
    }
}
