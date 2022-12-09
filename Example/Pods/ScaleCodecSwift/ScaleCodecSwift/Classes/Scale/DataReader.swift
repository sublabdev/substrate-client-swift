import Foundation

/// Handles `Data` reading
final class DataReader {
    private enum Error: Swift.Error {
        case invalidDataOffset
    }
    
    /// Actual data to read
    let data: Data
    /// An offset that shows how much has been read
    var offset = 0
    private var lastReadSize = 0
    
    init(data: Data) {
        self.data = data
    }
    
    var dataWithOffset: Data {
        data[offset..<data.count]
    }

    /// Reads data of a specified size
    /// - Parameters:
    ///     - size: The size of `Data` to be read
    /// - Returns: A byte array as result of reading the `Data`
    func read(size: Int) throws -> [UInt8] {
        let endIndex = offset + size
        
        guard endIndex <= data.count else {
            throw Error.invalidDataOffset
        }
        
        let result = data[offset..<endIndex]
        offset += size
        
        return Array(result)
    }
    
    /// Reads data by one byte (the size is set to one)
    /// - Returns: The first byte as a result of reading
    func readByte() throws -> UInt8 {
        try read(size: 1)[0]
    }
    /// Reads data till the end
    /// /// - Returns: A byte array as result of reading the `Data`
    func readToEnd() throws -> [UInt8] {
        try read(size: data.count - offset)
    }
    
    /// Reverts the offset
    func revert(offset: Int) {
        self.offset -= offset
    }
    /// Reverts the offset to the last read size
    func revertLast() {
        revert(offset: lastReadSize)
    }
}
