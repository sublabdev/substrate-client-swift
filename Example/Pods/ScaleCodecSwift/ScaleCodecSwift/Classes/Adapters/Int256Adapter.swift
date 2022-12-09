import Foundation
import CommonSwift

/// An adapter to handle read and write operations for Int256
class Int256Adapter: ScaleCodecAdapter<Int256> {
    override func read(_ type: Int256.Type, from reader: DataReader) throws -> Int256 {
        try Data(reader.read(size: Int256.size)).int256()
    }
    
    override func write(value: Int256) throws -> Data {
        value.data()
    }
}
