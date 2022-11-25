import Foundation

class NumericAdapter<T: FixedWidthInteger>: ScaleCodecAdapter<T> where T: Codable {
    override func read(_ type: T.Type, from reader: DataReader) throws -> T {
        let stride = MemoryLayout<T>.stride
        let bytes = try reader.read(size: stride)
        return T(littleEndian: bytes.withUnsafeBytes { $0.load(as: T.self) })
    }
    
    override func write(value: T) throws -> Data {
        var value = value
        return withUnsafeBytes(of: &value) { Data($0) }
    }
}
