import Foundation
import CommonSwift

/// An adapter to handle read and write operations for Int512
class Int512Adapter: ScaleCodecAdapter<Int512> {
    override func read(_ type: Int512.Type, from reader: DataReader) throws -> Int512 {
        try Data(reader.read(size: Int512.size)).int512()
    }
    
    override func write(value: Int512) throws -> Data {
        value.data()
    }
}
