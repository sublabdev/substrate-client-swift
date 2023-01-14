import Foundation

/// An extrinsic era
public enum Era: Equatable, Codable {
    case immortal
    case mortal(value: Mortal)
}

public struct Mortal: Equatable, Codable {
    public let period: UInt64
    public let phase: UInt64
}
