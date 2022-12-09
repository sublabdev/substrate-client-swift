import Foundation

/// A generic adapter that handles read and write operations for optionali types (conforming to `Codable` protocol)
class OptionalAdapter<T: Codable>: ScaleCodecAdapter<T?> {
    private let coder: ScaleCoder
    
    init(coder: ScaleCoder) {
        self.coder = coder
    }
    
    override func read(_ type: T?.Type, from reader: DataReader) throws -> T? {
        let isNil = try reader.readByte() == 0
        
        guard !isNil else {
            return nil
        }
        
        return try coder.decoder.decode(T.self, from: reader)
    }
    
    override func write(value: T?) throws -> Data {
        guard let value = value else {
            return .init([0])
        }
        
        let encoded = try coder.encoder.encode(value)
        return .init([1]) + encoded
    }
}

extension Optional: ScaleGenericCodable where Wrapped: Codable {
    init(from reader: DataReader, coder: ScaleCoder) throws {
        self = try OptionalAdapter(coder: coder).read(Wrapped?.self, from: reader)
    }
    
    func write(coder: ScaleCoder) throws -> Data {
        try OptionalAdapter(coder: coder).write(value: self)
    }
}
