import Foundation

final class ScaleSingleValueDecodingContainer: SingleValueDecodingContainer {
    private enum ScaleSingleValueDecodingError: Swift.Error {
        case noAdapter
        case decodingError
    }
    
    // MARK: - SingleValueDecodingContainer
    
    var codingPath: [CodingKey]
    let userInfo: [CodingUserInfoKey: Any]
    
    // MARK: - Init
    
    private let decoderProvider: ScaleDecoderProvider
    private var dataReader: DataReader
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
    }
    
    // MARK: - Decoding
    
    func decodeNil() -> Bool {
        do {
            let result = (((try dataReader.read(size: 1).first.map { $0 == 0b0 }) as Bool??)) == true
            dataReader.offset -= 1
            
            return result
        } catch {
            assertionFailure()
            return false
        }
    }
    
    func decode(_ type: Bool.Type) throws -> Bool {
        try read(type)
    }
    
    func decode(_ type: String.Type) throws -> String {
        try read(type)
    }
    
    func decode(_ type: Int.Type) throws -> Int {
        try read(type)
    }
    
    func decode(_ type: Int8.Type) throws -> Int8 {
        try read(type)
    }
    
    func decode(_ type: Int16.Type) throws -> Int16 {
        try read(type)
    }
    
    func decode(_ type: Int32.Type) throws -> Int32 {
        try read(type)
    }
    
    func decode(_ type: Int64.Type) throws -> Int64 {
        try read(type)
    }
    
    func decode(_ type: UInt.Type) throws -> UInt {
        try read(type)
    }
    
    func decode(_ type: UInt8.Type) throws -> UInt8 {
        try read(type)
    }
    
    func decode(_ type: UInt16.Type) throws -> UInt16 {
        try read(type)
    }
    
    func decode(_ type: UInt32.Type) throws -> UInt32 {
        try read(type)
    }
    
    func decode(_ type: UInt64.Type) throws -> UInt64 {
        try read(type)
    }
    
    func decode<T>(_ type: T.Type) throws -> T where T: Decodable {
        try read(type)
    }
    
    // MARK: - Private
    
    func read<T: Decodable>(_ type: T.Type) throws -> T {
        try adapterProvider.coder.decoder.decode(
            T.self,
            from: dataReader
        )
    }
}
