import Foundation
import Blake2

private extension Data {
    /// Blake hashing error types
    enum BlakeError: Error {
        case hashingFailure(String)
    }
    
    /// Hashes the data using blake2b
    /// - Parameters:
    ///     - size: The expected size (in bits) of Data
    ///     - Returns: Blake-hashed Data
    func blake2b(size: Int) throws -> Data {
        do {
            var hasher = try Blake2(.b2b, size: size / 8)
            hasher.update(self)
            
            return try hasher.finalize()
        } catch let error {
            throw BlakeError.hashingFailure(error.localizedDescription)
        }
    }
}

extension Hashing {
    /// Hashes the data using blake2b for 128 bits
    /// - Returns: Blake-hashed Data
    public func blake2b_128() throws -> Data {
        try data.blake2b(size: 128)
    }

    /// Hashes the data using blake2b for 160 bits
    /// - Returns: Blake-hashed Data
    public func blake2b_160() throws -> Data {
        try data.blake2b(size: 160)
    }

    /// Hashes the data using blake2b for 256 bits
    /// - Returns: Blake-hashed Data
    public func blake2b_256() throws -> Data {
        try data.blake2b(size: 256)
    }

    /// Hashes the data using blake2b for 384 bits
    /// - Returns: Blake-hashed Data
    public func blake2b_384() throws -> Data {
        try data.blake2b(size: 384)
    }

    /// Hashes the data using blake2b for 512 bits
    /// - Returns: Blake-hashed Data
    public func blake2b_512() throws -> Data {
        try data.blake2b(size: 512)
    }
}
