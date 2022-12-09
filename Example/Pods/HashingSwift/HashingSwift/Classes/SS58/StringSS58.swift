import Foundation

/// SS58 handler for String
public struct StringSS58 {
    private let string: String
    
    public init(string: String) {
        self.string = string
    }
    
    /// Public key from provided String value
    /// - Returns: The generated public key
    public func publicKey() throws -> Data {
        do {
            let decodedData = try decode()
            let networkTypeLength = try networkTypeLength(data: decodedData)
            let publicKey = decodedData[(networkTypeLength..<networkTypeLength + SS58.publicKeySize)]
            
            // check sum
            guard let prefixData = SS58.prefix.data(using: .utf8) else {
                throw SS58.Error.noDataException
            }
            
            let checkData = prefixData + decodedData[0..<networkTypeLength] + publicKey
            let checksum = try checkData.hashing.blake2b_512()[0..<SS58.prefixSize]
            let checkFrom = networkTypeLength + SS58.publicKeySize
            let check = decodedData[checkFrom..<checkFrom + SS58.prefixSize]
            
            guard check == checksum else {
                throw SS58.Error.invalidChecksumException
            }
            
            return publicKey
        } catch let error {
            throw SS58.Error.decodingFailure(error.localizedDescription)
        }
    }
    
    /// The network type from provided String value
    /// - Returns: The network type
    public func networkType() throws -> UInt {
        do {
            let decodedData = try decode()
            let first = UInt(decodedData[0])
            
            switch try networkTypeLength(data: decodedData) {
            case 1:
                return first
            case 2:
                let second = UInt(decodedData[1])
                let lo = ((first & 0x3f) << 2) | (second >> 6)
                let hi = (second & 0x3f) << 8
                
                return lo | hi
                
            default:
                throw SS58.Error.invalidAddressException
            }
        } catch let error {
            throw SS58.Error.decodingFailure(error.localizedDescription)
        }
    }
    
    // Getting the network type length
    private func networkTypeLength(data: Data) throws -> UInt {
        switch UInt(data[0]) {
        case SS58.networkTypeLengthRange1:
            return 1
        case SS58.networkTypeLengthRange2:
            return 2
            
        default:
            throw SS58.Error.invalidAddressException
        }
    }
    
    // Decoding the provided String value using Base58
    private func decode() throws -> Data {
        let result = string.base58.decode()
        
        if result.count < 2 {
            throw SS58.Error.invalidAddressException
        }
        
        return result
    }
}

extension String {
    /// And access point for SS58 functionality for String
    public var ss58: StringSS58 {
        .init(string: self)
    }
}
