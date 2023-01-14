import Foundation

/// An extrinsic era
enum Era: Equatable {
    case immortal(value: Immortal)
    case mortal(value: Mortal)
}

// TODO: Check Immortal's logic here
struct Immortal: Hashable, Equatable {
}

struct Mortal: Equatable {
    let period: UInt64
    let phase: UInt64
}
