import BigInt
import Foundation

class ArrayAdapter<T: Codable>: ScaleCodecAdapter<[T]> {
    private let coder: ScaleCoder
    
    init(coder: ScaleCoder) {
        self.coder = coder
    }
    
    override func read(_ type: [T].Type, from reader: DataReader) throws -> [T] {
        let count = try coder.decoder.decode(BigUInt.self, from: reader)
        return try (0..<count).map { _ in try coder.decoder.decode(T.self, from: reader) }
    }
    
    override func write(value: [T]) throws -> Data {
        try value
            .map { try coder.encoder.encode($0) }
            .reduce(try coder.encoder.encode(BigUInt(value.count))) { $0 + $1 }
    }
}

extension Array: ScaleGenericCodable where Element: Codable {
    init(from reader: DataReader, coder: ScaleCoder) throws {
        self = try ArrayAdapter(coder: coder).read([Element].self, from: reader)
    }
    
    func write(coder: ScaleCoder) throws -> Data {
        try ArrayAdapter(coder: coder).write(value: self)
    }
}