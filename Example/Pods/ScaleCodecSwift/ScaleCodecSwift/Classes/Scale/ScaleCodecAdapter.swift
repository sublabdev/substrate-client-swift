import Foundation

/// TODO: Add a doc
protocol ScaleCodecAdaptable {
}

open class ScaleCodecAdapter<T>: ScaleCodecAdaptable {
    func read(_ type: T.Type, from reader: DataReader) throws -> T where T: Decodable {
        fatalError("not implemented")
    }
    
    func write(value: T) throws -> Data where T: Encodable {
        fatalError("not implemented")
    }
}
