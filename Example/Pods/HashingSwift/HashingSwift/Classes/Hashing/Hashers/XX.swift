import Foundation
import xxHash_Swift
import CommonSwift

private extension Data {
    /// Decodes data using XX hash algorithm
    /// - Parameters:
    ///     - width: The expected width of data
    ///     - Returns: XX-decoded data
    func xx(width: Int64) -> Data {
        (0..<width / 64).compactMap {
            let xxHash64 = XXH64(UInt64($0))
            let _ = xxHash64.update(self)
            guard let result = xxHash64.digestHex().hex.decode()?.reversed() else {
                return Data()
            }
            return Data(result)
        }
        .reduce(Data()) { $0 + $1 }
    }
}

extension Hashing {
    /// Decodes data using XX hash algorithm with width of 64 bits
    /// - Returns: XX-decoded data
    public func xx64() -> Data {
        data.xx(width: 64)
    }
    
    /// Decodes data using XX hash algorithm with width of 128 bits
    /// - Returns: XX-decoded data
    public func xx128() -> Data {
        data.xx(width: 128)
    }
    
    /// Decodes data using XX hash algorithm with width of 256 bits
    /// - Returns: XX-decoded data
    public func xx256() -> Data {
        data.xx(width: 256)
    }
}
