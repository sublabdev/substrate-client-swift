import Foundation

/// Wrapper over Data for working with SS58
public struct DataSS58 {
    private let data: Data
    
    public init(data: Data) {
        self.data = data
    }
    
    /// Return `AccountId` hashed using blake2b for 256 bits if the provided data is
    /// bigger then `SS58`'s public key's size. Otherwise return a plain `AccountId`.
    /// The method might throw an error.
    ///  - Returns: `AccountId` either hashed or plain.
    public func accountId() throws -> AccountId {
        if data.count > SS58.publicKeySize {
            do {
                return try data.hashing.blake2b_256()
            } catch {
                throw SS58.Error.invalidPublicKey
            }
        } else {
            return data
        }
    }
    
    /// Address for a specific network type
    ///  - Returns: An address based on the provided network type
    public func address(type: UInt) throws -> String {
        guard let prefix = SS58.prefix.data(using: .utf8) else {
            throw SS58.Error.internal
        }
        
        let accountId = try accountId()
        
        let single = type & 0x3fff
        var networkType: [UInt8?]
        let networkTypeLength: Int
        
        switch type {
        case SS58.networkTypeLengthRange1:
            networkType = [.init(exactly: type)]
            networkTypeLength = 1
            
        case SS58.networkTypeLengthRange2:
            let hi = ((single & 0xfc) >> 2) | 0x40
            let lo = (single >> 8) | ((single & 0x3f) << 6)
            
            networkType = [.init(exactly: hi), .init(exactly: lo)]
            networkTypeLength = 2
            
        default:
            throw SS58.Error.invalidAddressException
        }
        
        let networkTypeData = Data(networkType.compactMap { $0 })
        
        guard networkTypeData.count == networkTypeLength
        else {
            throw SS58.Error.internal
        }
        
        let checksum = try (prefix + networkTypeData + accountId).hashing.blake2b_512()[0..<SS58.prefixSize]
        return (networkTypeData + accountId + checksum).base58.encode()
    }
}

extension Data {
    /// An access point to SS58 functionality for Data
    public var ss58: DataSS58 {
        .init(data: self)
    }
}
