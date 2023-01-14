import Foundation
import ScaleCodecSwift

/// Runtime version
public struct RuntimeVersion: Codable {
    public let specName: String
    public let implName: String
    public let authoringVersion: Index
    public let specVersion: Index
    public let implVersion: Index
    public let apis: [RuntimeVersionApi]
    public let txVersion: Index
    public let stateVersion: UInt8
}

public struct RuntimeVersionApi: Codable {
    @Array8 public var id: [UInt8]
    public let index: Index
}
