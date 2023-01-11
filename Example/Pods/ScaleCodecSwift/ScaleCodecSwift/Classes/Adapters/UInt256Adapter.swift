import Foundation
import CommonSwift

/// An adapter to handle read and write operations for UInt256
public class UInt256Adapter: ScaleCodecAdapter<UInt256> {
    public override init() {}
    
    public override func read(_ type: UInt256.Type, from reader: DataReader) throws -> UInt256 {
        try Data(reader.read(size: UInt256.size)).uInt256()
    }
    
    public override func write(value: UInt256) throws -> Data {
        value.data()
    }
}
