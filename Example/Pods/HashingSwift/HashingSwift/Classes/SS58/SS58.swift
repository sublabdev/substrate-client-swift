import Foundation

/// SS58 constants' holder
struct SS58 {
    /// SS58-related errors
    enum Error: Swift.Error {
        case invalidAddressException
        case invalidChecksumException
        case `internal`
        case noDataException
        case decodingFailure(String)
        case invalidPublicKey
    }
    
    static let networkTypeLengthRange1: ClosedRange<UInt> = 0...63
    static let networkTypeLengthRange2: ClosedRange<UInt> = 64...16383
    static let publicKeySize: UInt = 32
    static let prefix = "SS58PRE"
    static let prefixSize: UInt = 2
}
