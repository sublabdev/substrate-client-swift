import Foundation
import CommonSwift

/// An adapter to handle read and write operations for Int128
public class Int128Adapter: ScaleCodecAdapter<Int128> {
    public override init() {}
    
    public override func read(_ type: Int128.Type, from reader: DataReader) throws -> Int128 {
        try Data(reader.read(size: Int128.size)).int128()
    }
    
    public override func write(value: Int128) throws -> Data {
        value.data()
    }
}
