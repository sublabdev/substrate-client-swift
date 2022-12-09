import Foundation

final class ScaleSingleValueEncodingContainer: SingleValueEncodingContainer, ScaleEncodingContainer {
    private enum ScaleSingleValueEncodingError: Swift.Error {
        case noAdapter
    }
    
    // MARK: - SingleValueEncodingContainer
    
    let codingPath: [CodingKey]
    let userInfo: [CodingUserInfoKey: Any]
    
    // MARK: - ScaleEncodingContainer
    
    private var _data: Data?
    private let adapterProvider: ScaleCodecAdapterProvider
    var data: Data { _data ?? Data() }
    
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
    }
    
    // MARK: - Encoding
    // Checks whether the provided value can be encoded or not
    private func checkCanEncode(value: Any?) throws {
        guard _data == nil else {
            let context = EncodingError.Context(
                codingPath: codingPath,
                debugDescription: "Single value container already contains encoded value"
            )
            
            throw EncodingError.invalidValue(value as Any, context)
        }
    }
    
    // Encodes nil values
    func encodeNil() throws {
        try checkCanEncode(value: nil)
        _data = Data([0])
    }
    // Encodes not nil values
    func encodeNotNil() throws {
        try checkCanEncode(value: nil)
        _data = Data([1])
    }
    // Encodes Bool values
    func encode(_ value: Bool) throws {
        try checkCanEncode(value: value)
        _data = try write(value)
    }
    // Encodes optional Bool values
    func encode(_ value: Bool?) throws {
        try checkCanEncode(value: value)
        _data = try write(value)
    }
    // Encodes Int values
    func encode(_ value: Int) throws {
        try checkCanEncode(value: value)
        _data = try write(value)
        
    }
    // Encodes Int8 values
    func encode(_ value: Int8) throws {
        try checkCanEncode(value: value)
        _data = try write(value)
    }
    // Encodes Int16 values
    func encode(_ value: Int16) throws {
        try checkCanEncode(value: value)
        _data = try write(value)
    }
    // Encodes Int32 values
    func encode(_ value: Int32) throws {
        try checkCanEncode(value: value)
        _data = try write(value)
    }
    // Encodes Int64 values
    func encode(_ value: Int64) throws {
        try checkCanEncode(value: value)
        _data = try write(value)
    }
    // Encodes UInt values
    func encode(_ value: UInt) throws {
        try checkCanEncode(value: value)
        _data = try write(value)
    }
    // Encodes UInt8 values
    func encode(_ value: UInt8) throws {
        try checkCanEncode(value: value)
        _data = try write(value)
    }
    // Encodes UInt16 values
    func encode(_ value: UInt16) throws {
        try checkCanEncode(value: value)
        _data = try write(value)
    }
    // Encodes UInt32 values
    func encode(_ value: UInt32) throws {
        try checkCanEncode(value: value)
        _data = try write(value)
    }
    // Encodes UInt64 values
    func encode(_ value: UInt64) throws {
        try checkCanEncode(value: value)
        _data = try write(value)
    }
    // Encodes generic T values
    func encode<T>(_ value: T) throws where T : Encodable {
        try checkCanEncode(value: value)
        _data = try write(value)
    }
    
    // MARK: - Private
    // Writes generic T types
    func write<T: Encodable>(_ value: T) throws -> Data {
        try adapterProvider.coder.encoder.encode(value)
    }
}
