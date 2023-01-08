//
//  Sr25519Seed.swift
//  
//
//  Created by Yehor Popovych on 25.03.2021.
//

import Foundation
#if !COCOAPODS
import CSr25519
import Sr25519Helpers
#endif

public struct Sr25519Seed {
    let seed: sr25519_mini_secret_key
    
    public init() {
        try! self.init(raw: Data(Sr25519SecureRandom.bytes(count: Self.size)))
    }
    
    public init(raw: Data) throws {
        guard raw.count == Self.size else {
            throw Sr25519Error.badSeedLength(
                length: raw.count, expected: Self.size
            )
        }
        self.init(seed: try! TCArray.new(raw: raw))
    }
    
    init(seed: sr25519_mini_secret_key) {
        self.seed = seed
    }
    
    public var raw: Data {
        TCArray.get(raw: seed)
    }
    
    public static let size: Int = MemoryLayout<sr25519_mini_secret_key>.size
}

extension Sr25519Seed: Equatable {
    public static func == (lhs: Sr25519Seed, rhs: Sr25519Seed) -> Bool {
        TCArray.equal(lhs.seed, rhs.seed)
    }
}

extension Sr25519Seed: Hashable {
    public func hash(into hasher: inout Hasher) {
        TCArray.hash(seed, in: &hasher)
    }
}
