import Foundation

/// A generic numeric adapter that handles read and write operations for numeric types (conforming to `FixedWidthInteger` protocol)
public class NumericAdapter<T: FixedWidthInteger>: ScaleCodecAdapter<T> where T: Codable {
    public override init() {}
    
    public override func read(_ type: T.Type, from reader: DataReader) throws -> T {
        let stride = MemoryLayout<T>.stride
        return Self.fromData(try reader.read(size: stride))
    }
    
    public static func fromData(_ data: Data) -> T {
        fromData(data.map { $0 })
    }
    
    static func fromData(_ data: [UInt8]) -> T {
        T(littleEndian: data.withUnsafeBytes { $0.load(as: T.self) })
    }
    
    public override func write(value: T) throws -> Data {
        Self.toData(value)
    }
    
    public static func toData(_ value: T) -> Data {
        var value = value
        return withUnsafeBytes(of: &value) { Data($0) }
    }
}
