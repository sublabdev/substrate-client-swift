import Foundation
import CommonSwift

/// An adapter to handle read and write operations for UInt512
class UInt512Adapter: ScaleCodecAdapter<UInt512> {
    override func read(_ type: UInt512.Type, from reader: DataReader) throws -> UInt512 {
        try Data(reader.read(size: UInt512.size)).uInt512()
    }
    
    override func write(value: UInt512) throws -> Data {
        value.data()
    }
}
