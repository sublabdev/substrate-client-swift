import Foundation

/// An adapter for Bool type
public final class BoolAdapter: ScaleCodecAdapter<Bool> {
    public override init() {}
    
    public override func read(_ type: Bool.Type, from reader: DataReader) throws -> Bool {
        try reader.readByte() == 1
    }
    
    public override func write(value: Bool) throws -> Data {
        Data([value ? 1 : 0])
    }
}

/// An adapter for Bool? type
public final class OptionalBoolAdapter: ScaleCodecAdapter<Bool?> {
    private enum Error: Swift.Error {
        case invalidValue(UInt8)
    }
    
    public override func read(_ type: Bool?.Type, from reader: DataReader) throws -> Bool? {
        switch try reader.readByte() {
        case 0: return nil
        case 1: return true
        case 2: return false
        default: throw Error.invalidValue(3)
        }
    }
    
    public override func write(value: Bool?) throws -> Data {
        Data([value.map { $0 ? 1 : 2 } ?? 0])
    }
}
