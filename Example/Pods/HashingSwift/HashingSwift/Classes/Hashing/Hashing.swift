import Foundation

/// A wrapper over data for providing a similar interface
public struct Hashing {
    let data: Data
    
    public init(data: Data) {
        self.data = data
    }
}

extension Data {
    /// A point of access to all hashing functionality for Data
    public var hashing: Hashing {
        .init(data: self)
    }
}

extension String {
    /// A point of access to all hashing functionality for String
    public var hashing: Hashing {
        .init(data: data(using: .utf8) ?? Data())
    }
}
