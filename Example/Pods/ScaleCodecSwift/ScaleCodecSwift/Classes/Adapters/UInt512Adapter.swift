import Foundation
import CommonSwift

/// An adapter to handle read and write operations for UInt512
public class UInt512Adapter: ScaleCodecAdapter<UInt512> {
    public override init() {}
    
    public override func read(_ type: UInt512.Type, from reader: DataReader) throws -> UInt512 {
        try Data(reader.read(size: UInt512.size)).uInt512()
    }
    
    public override func write(value: UInt512) throws -> Data {
        value.data()
    }
}
