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
    
    private func checkCanEncode(value: Any?) throws {
        guard _data == nil else {
            let context = EncodingError.Context(
                codingPath: codingPath,
                debugDescription: "Single value container already contains encoded value"
            )
            
            throw EncodingError.invalidValue(value as Any, context)
        }
    }
    
    func encodeNil() throws {
        try checkCanEncode(value: nil)
        _data = Data([0])
    }
    
    func encodeNotNil() throws {
        try checkCanEncode(value: nil)
        _data = Data([1])
    }
    
    func encode(_ value: Bool) throws {
        try checkCanEncode(value: value)
        _data = try write(value)
    }
    
    func encode(_ value: Bool?) throws {
        try checkCanEncode(value: value)
        _data = try write(value)
    }
    
    func encode(_ value: Int) throws {
        try checkCanEncode(value: value)
        _data = try write(value)
        
    }
    
    func encode(_ value: Int8) throws {
        try checkCanEncode(value: value)
        _data = try write(value)
    }
    
    func encode(_ value: Int16) throws {
        try checkCanEncode(value: value)
        _data = try write(value)
    }
    
    func encode(_ value: Int32) throws {
        try checkCanEncode(value: value)
        _data = try write(value)
    }
    
    func encode(_ value: Int64) throws {
        try checkCanEncode(value: value)
        _data = try write(value)
    }
    
    func encode(_ value: UInt) throws {
        try checkCanEncode(value: value)
        _data = try write(value)
    }
    
    func encode(_ value: UInt8) throws {
        try checkCanEncode(value: value)
        _data = try write(value)
    }
    
    func encode(_ value: UInt16) throws {
        try checkCanEncode(value: value)
        _data = try write(value)
    }
    
    func encode(_ value: UInt32) throws {
        try checkCanEncode(value: value)
        _data = try write(value)
    }
    
    func encode(_ value: UInt64) throws {
        try checkCanEncode(value: value)
        _data = try write(value)
    }
    
    func encode<T>(_ value: T) throws where T : Encodable {
        try checkCanEncode(value: value)
        _data = try write(value)
    }
    
    // MARK: - Private
    
    func write<T: Encodable>(_ value: T) throws -> Data {
        try adapterProvider.coder.encoder.encode(value)
    }
}
