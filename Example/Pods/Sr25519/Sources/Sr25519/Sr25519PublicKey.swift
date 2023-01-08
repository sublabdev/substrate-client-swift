//
//  Sr25519PublicKey.swift
//  
//
//  Created by Yehor Popovych on 25.03.2021.
//

import Foundation
#if !COCOAPODS
import CSr25519
import Sr25519Helpers
#endif

public struct Sr25519PublicKey {
    let key: sr25519_public_key
    
    public init(raw: Data) throws {
        guard raw.count == Self.size else {
            throw Sr25519Error.badPublicKeyLength(
                length: raw.count, expected: Self.size
            )
        }
        self.init(key: try! TCArray.new(raw: raw))
    }
    
    init(key: sr25519_public_key) {
        self.key = key
    }
    
    public var raw: Data {
        TCArray.get(raw: key)
    }
    
    public func verify(message: Data, signature: Sr25519Signature) -> Bool {
        TCArray
            .pointer(of: (UInt8.self, UInt8.self))
            .wrap(key, signature.signature) { kp, sp in
                message.withUnsafeBytes { mes -> Bool in
                    let message = mes.bindMemory(to: UInt8.self)
                    return sr25519_verify(
                        sp.baseAddress, message.baseAddress, UInt(message.count), kp.baseAddress
                    )
                }
            }
    }
    
    public func derive(chainCode: Sr25519ChainCode) -> Sr25519PublicKey {
        var newKey: sr25519_public_key = TCArray.new()
        TCArray
            .pointer(of: (UInt8.self, UInt8.self, UInt8.self))
            .wrap(&newKey, key, chainCode.code) { nkp, kp, cp in
                sr25519_derive_public_soft(nkp.baseAddress, kp.baseAddress, cp.baseAddress)
            }
        return Sr25519PublicKey(key: newKey)
    }
    
    public static let size: Int = MemoryLayout<sr25519_public_key>.size
}

extension Sr25519PublicKey: Equatable {
    public static func == (lhs: Sr25519PublicKey, rhs: Sr25519PublicKey) -> Bool {
        TCArray.equal(lhs.key, rhs.key)
    }
}

extension Sr25519PublicKey: Hashable {
    public func hash(into hasher: inout Hasher) {
        TCArray.hash(key, in: &hasher)
    }
}
