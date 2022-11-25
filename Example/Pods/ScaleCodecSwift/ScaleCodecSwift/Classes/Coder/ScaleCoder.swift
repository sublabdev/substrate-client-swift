import Foundation

public final class ScaleCoder {
    public let encoder: ScaleEncoder
    public let decoder: ScaleDecoder
    
    public init(encoder: ScaleEncoder, decoder: ScaleDecoder) {
        self.encoder = encoder
        self.decoder = decoder
    }
}
