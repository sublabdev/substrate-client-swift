import Foundation

/// An object that holds an encoder and a decoder
public final class ScaleCoder {
    /// Encoder used to encode (write) data from a specified type to Data
    public let encoder: ScaleEncoder
    /// Decoder used to decode (read) data to a specified type
    public let decoder: ScaleDecoder
    
    public let adapterProvider: ScaleCodecAdapterProvider
    
    public init(adapterProvider: ScaleCodecAdapterProvider) {
        self.adapterProvider = adapterProvider
        self.encoder = ScaleEncoder(adapterProvider: adapterProvider)
        self.decoder = ScaleDecoder(adapterProvider: adapterProvider)
    }
    
    /// Creates a default coder that handles all the standard types
    /// - Returns: A default `ScaleCoder` created using the default adapter provider
    public static func `default`() -> ScaleCoder {
        .init(adapterProvider: DefaultScaleCodecAdapterProvider())
    }
    
    /// A transaction object for scale coded
    /// - Returns: An object which is used to decode (by appending additional values if needed) and encode
    /// `Codable` types
    public func transaction() -> ScaleCodecTransaction {
        ScaleCodecTransaction(encoder: encoder)
    }
}
