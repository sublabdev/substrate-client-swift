import Foundation

/// Handles Scale Codec transaction for `Codable` types. Provides an mechanism for encoding and appending multiple
/// values, conforming to `Codable` and decode them.
public class ScaleCodecTransaction {
    private let encoder: ScaleEncoder
    private var data = Data()
    
    init(encoder: ScaleEncoder) {
        self.encoder = encoder
    }
    
    /// Appends additional `Codable` objects to existing encoded data
    /// - Returns: Returns `self` with updated encoded data
    public func append<T: Codable>(_ value: T) throws -> Self {
        data += try encoder.encode(value)
        return self
    }
    
    /// Decodes the existing encoded data
    /// - Returns: An accumulated data of previously encoded objects
    public func commit() -> Data {
        data
    }
}
