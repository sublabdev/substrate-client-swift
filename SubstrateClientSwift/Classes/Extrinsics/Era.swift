import Foundation

/// An extrinsic era
public enum Era: Equatable, Codable {
    enum CodingKeys: Int, CodingKey {
        case immortal = 0
        case mortal = 1
    }
    
    case immortal
    case mortal(value: Mortal)
}

public struct Mortal: Equatable, Codable {
    public let period: UInt64
    public let phase: UInt64
}
