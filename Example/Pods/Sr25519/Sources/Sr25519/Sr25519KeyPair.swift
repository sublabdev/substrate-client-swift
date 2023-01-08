//
//  Sr25519KeyPair.swift
//  
//
//  Created by Yehor Popovych on 25.03.2021.
//

import Foundation
#if !COCOAPODS
import CSr25519
import Sr25519Helpers
#endif

public struct Sr25519KeyPair {
    private let _private: sr25519_secret_key
    private let _public: Sr25519PublicKey
    
    public init(seed: Sr25519Seed) {
        var pair: sr25519_keypair = TCArray.new()
        TCArray
            .pointer(of: (UInt8.self, UInt8.self))
            .wrap(&pair, seed.seed) { kp, sd in
                sr25519_keypair_from_seed(kp.baseAddress, sd.baseAddress)
            }
        self.init(keypair: pair)
    }
    
    public init(raw: Data) throws {
        guard raw.count == Self.size else {
            throw Sr25519Error.badKeyPairLength(
                length: raw.count, expected: Self.size
            )
        }
        self.init(keypair: try! TCArray.new(raw: raw))
    }
    
    init(keypair: sr25519_keypair) {
        (_private, _public) = TCArray
            .pointer(of: UInt8.self)
            .wrap(keypair) { u8 in
                return (
                    try! TCArray.new(raw: Data(u8[0..<Self.secretSize])),
                    Sr25519PublicKey(key: try! TCArray.new(raw: Data(u8[Self.secretSize..<Self.size])))
                )
            }
    }
    
    public var publicKey: Sr25519PublicKey { _public }
    
    public var raw: Data { TCArray.get(raw: keyPair) }
    public var privateRaw: Data { TCArray.get(raw: _private) }
    
    public func derive(chainCode: Sr25519ChainCode, hard: Bool) -> Sr25519KeyPair {
        var out: sr25519_keypair = TCArray.new()
        TCArray
            .pointer(of: (UInt8.self, UInt8.self, UInt8.self))
            .wrap(&out, keyPair, chainCode.code) { op, kpp, ccp in
                if hard {
                    sr25519_derive_keypair_hard(op.baseAddress, kpp.baseAddress, ccp.baseAddress)
                } else {
                    sr25519_derive_keypair_soft(op.baseAddress, kpp.baseAddress, ccp.baseAddress)
                }
            }
        return Sr25519KeyPair(keypair: out)
    }
    
    public func sign(message: Data) -> Sr25519Signature {
        var out: sr25519_signature = TCArray.new()
        TCArray
            .pointer(of: (UInt8.self, UInt8.self, UInt8.self))
            .wrap(&out, _private, _public.key) { sp, privp, pubp in
                message.withUnsafeBytes { mes in
                    let message = mes.bindMemory(to: UInt8.self)
                    sr25519_sign(
                        sp.baseAddress, pubp.baseAddress, privp.baseAddress,
                        message.baseAddress, UInt(message.count)
                    )
                }
            }
        return Sr25519Signature(signature: out)
    }
    
    public func verify(message: Data, signature: Sr25519Signature) -> Bool {
        _public.verify(message: message, signature: signature)
    }
    
    var keyPair: sr25519_keypair {
        try! TCArray.new(raw: TCArray.get(raw: _private) + TCArray.get(raw: _public.key))
    }
    
    public static let size: Int = MemoryLayout<sr25519_keypair>.size
    public static let secretSize: Int = MemoryLayout<sr25519_secret_key>.size
}

extension Sr25519KeyPair: Equatable {
    public static func == (lhs: Sr25519KeyPair, rhs: Sr25519KeyPair) -> Bool {
        TCArray.equal(lhs._private, rhs._private) && lhs._public == rhs._public
    }
}

extension Sr25519KeyPair: Hashable {
    public func hash(into hasher: inout Hasher) {
        TCArray.hash(_private, in: &hasher)
        hasher.combine(_public)
    }
}
