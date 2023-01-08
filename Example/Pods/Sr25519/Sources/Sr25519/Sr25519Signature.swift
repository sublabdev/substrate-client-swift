//
//  Sr25519Signature.swift
//  
//
//  Created by Yehor Popovych on 25.03.2021.
//

import Foundation
#if !COCOAPODS
import CSr25519
import Sr25519Helpers
#endif

public struct Sr25519Signature {
    let signature: sr25519_signature
    
    public init(raw: Data) throws {
        guard raw.count == Self.size else {
            throw Sr25519Error.badSignatureLength(
                length: raw.count,
                expected: Self.size
            )
        }
        self.init(signature: try! TCArray.new(raw: raw))
    }
    
    init(signature: sr25519_signature) {
        self.signature = signature
    }
    
    public var raw: Data {
        TCArray.get(raw: signature)
    }
    
    public func verify(for message: Data, key: Sr25519PublicKey) -> Bool {
        key.verify(message: message, signature: self)
    }
    
    public func verify(for message: Data, pair: Sr25519KeyPair) -> Bool {
        pair.verify(message: message, signature: self)
    }
    
    public static let size: Int = MemoryLayout<sr25519_signature>.size
}

extension Sr25519Signature: Equatable {
    public static func == (lhs: Sr25519Signature, rhs: Sr25519Signature) -> Bool {
        TCArray.equal(lhs.signature, rhs.signature)
    }
}

extension Sr25519Signature: Hashable {
    public func hash(into hasher: inout Hasher) {
        TCArray.hash(signature, in: &hasher)
    }
}
