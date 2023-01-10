import Foundation
import BigInt

extension BigInt {
    
    /// Initialize a BigInt from bytes accessed from an `UnsafeRawBufferPointer`,
    /// where the first byte indicates sign (0 for positive, 1 for negative)
    /// /// - Parameters:
    ///     - buffer: Аn `UnsafeRawBufferPointer` from where bytes are accessed
    public init(_ buffer: UnsafeRawBufferPointer) {
        // This assumes Word is binary.
        precondition(Word.bitWidth % 8 == 0)
        
        self.init()
        
        let length = buffer.count
        
        // Serialized data for a BigInt should contain at least 2 bytes: one representing
        // the sign, and another for the non-zero magnitude. Zero is represented by an
        // empty Data struct, and negative zero is not supported.
        guard length > 1, let firstByte = buffer.first else { return }

        // The first byte gives the sign
        // This byte is compared to a bitmask to allow additional functionality to be added
        // to this byte in the future.
        self.sign = firstByte & 0b1 == 0 ? .plus : .minus

        self.magnitude = BigUInt(UnsafeRawBufferPointer(rebasing: buffer.dropFirst(1)))
    }
    
    /// Initializes an integer from the bits stored inside a piece of `Data`.
    /// The data is assumed to be in network (big-endian) byte order with a first
    /// byte to represent the sign (0 for positive, 1 for negative)
    /// - Parameters:
    ///     - data: In network (big-endian) byte order `Data` inside of which the bits for an integer initialization are stored
    public init(_ data: Data) {
        // This assumes Word is binary.
        // This is the same assumption made when initializing BigUInt from Data
        precondition(Word.bitWidth % 8 == 0)

        self.init()
        
        // Serialized data for a BigInt should contain at least 2 bytes: one representing
        // the sign, and another for the non-zero magnitude. Zero is represented by an
        // empty Data struct, and negative zero is not supported.
        guard data.count > 1, let firstByte = data.first else { return }
        
        // The first byte gives the sign
        // This byte is compared to a bitmask to allow additional functionality to be added
        // to this byte in the future.
        self.sign = firstByte & 0b1 == 0 ? .plus : .minus
        
        // The remaining bytes are read and stored as the magnitude
        self.magnitude = BigUInt(data.dropFirst(1))
    }
    
    /// Return a `Data` value that contains the base-256 representation of this integer, in network (big-endian) byte order and a prepended byte to indicate the sign (0 for positive, 1 for negative)
    /// - Returns: A `Data` value that contains the base-256 representation of this integer
    public func serialize() -> Data {
        // Create a data object for the magnitude portion of the BigInt
        let magnitudeData = self.magnitude.serialize()
        
        // Similar to BigUInt, a value of 0 should return an initialized, empty Data struct
        guard magnitudeData.count > 0 else { return magnitudeData }
        
        // Create a new Data struct for the signed BigInt value
        var data = Data(capacity: magnitudeData.count + 1)
        
        // The first byte should be 0 for a positive value, or 1 for a negative value
        // i.e., the sign bit is the LSB
        data.append(self.sign == .plus ? 0 : 1)
        
        data.append(magnitudeData)
        return data
    }
}
