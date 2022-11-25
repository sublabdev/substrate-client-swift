import Foundation

final class DataReader {
    private enum Error: Swift.Error {
        case invalidDataOffset
    }
    
    let data: Data
    var offset = 0
    private var lastReadSize = 0
    
    init(data: Data) {
        self.data = data
    }
    
    var dataWithOffset: Data {
        data[offset..<data.count]
    }

    func read(size: Int) throws -> [UInt8] {
        let endIndex = offset + size
        
        guard endIndex <= data.count else {
            throw Error.invalidDataOffset
        }
        
        let result = data[offset..<endIndex]
        offset += size
        
        return Array(result)
    }
    
    func readByte() throws -> UInt8 {
        try read(size: 1)[0]
    }
    
    func readToEnd() throws -> [UInt8] {
        try read(size: data.count - offset)
    }
    
    func revert(offset: Int) {
        self.offset -= offset
    }
    
    func revertLast() {
        revert(offset: lastReadSize)
    }
}
