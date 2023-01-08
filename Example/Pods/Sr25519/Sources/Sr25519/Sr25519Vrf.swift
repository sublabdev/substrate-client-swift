//
//  Sr25519Vrf.swift
//  
//
//  Created by Yehor Popovych on 25.03.2021.
//

import Foundation
#if !COCOAPODS
import CSr25519
import Sr25519Helpers
#endif

public struct Sr25519VrfSignature {
    let output: sr25519_vrf_output
    let proof: sr25519_vrf_proof
    
    public init(raw: Data) throws {
        guard raw.count == Self.size else {
            throw Sr25519Error.badVrfSignatureLength(
                length: raw.count, expected: Self.size
            )
        }
        self.init(signature: try! TCArray.new(raw: raw))
    }
    
    init(signature: sr25519_vrf_out_and_proof) {
        (output, proof) = TCArray
            .pointer(of: UInt8.self)
            .wrap(signature) { u8 in
                return (
                    try! TCArray.new(raw: Data(u8[0..<Self.outputSize])),
                    try! TCArray.new(raw: Data(u8[Self.outputSize..<Self.size]))
                )
            }
    }
    
    public var raw: Data {
        TCArray.get(raw: output) + TCArray.get(raw: proof)
    }
    
    public func verify(for message: Data, key: Sr25519PublicKey, threshold: Sr25519VrfThreshold) -> Bool {
        key.vrfVerify(message: message, signature: self, threshold: threshold)
    }
    
    public func verify(for message: Data, pair: Sr25519KeyPair, threshold: Sr25519VrfThreshold) -> Bool {
        pair.vrfVerify(message: message, signature: self, threshold: threshold)
    }
    
    public static let size: Int = MemoryLayout<sr25519_vrf_out_and_proof>.size
    public static let outputSize: Int = MemoryLayout<sr25519_vrf_output>.size
    public static let proofSize: Int = MemoryLayout<sr25519_vrf_proof>.size
}

extension Sr25519VrfSignature: Equatable {
    public static func == (lhs: Sr25519VrfSignature, rhs: Sr25519VrfSignature) -> Bool {
        TCArray.equal(lhs.output, rhs.output) && TCArray.equal(lhs.proof, rhs.proof)
    }
}

extension Sr25519VrfSignature: Hashable {
    public func hash(into hasher: inout Hasher) {
        TCArray.hash(output, in: &hasher)
        TCArray.hash(proof, in: &hasher)
    }
}

public struct Sr25519VrfThreshold {
    let threshold: sr25519_vrf_threshold
    
    public init() {
        try! self.init(raw: Data(repeating: 0xFF, count: Self.size))
    }
    
    public init(raw: Data) throws {
        guard raw.count == Self.size else {
            throw Sr25519Error.badVrfThresholdLength(
                length: raw.count, expected: Self.size
            )
        }
        self.init(threshold: try! TCArray.new(raw: raw))
    }
    
    init(threshold: sr25519_vrf_threshold) {
        self.threshold = threshold
    }
    
    public static let size: Int = MemoryLayout<sr25519_vrf_threshold>.size
}

extension Sr25519VrfThreshold: Equatable {
    public static func == (lhs: Sr25519VrfThreshold, rhs: Sr25519VrfThreshold) -> Bool {
        TCArray.equal(lhs.threshold, rhs.threshold)
    }
}

extension Sr25519VrfThreshold: Hashable {
    public func hash(into hasher: inout Hasher) {
        TCArray.hash(threshold, in: &hasher)
    }
}

extension Sr25519KeyPair {
    internal var vrfKeyPair: sr25519_keypair {
        var vrf: sr25519_keypair = TCArray.new()
        TCArray
            .pointer(of: (UInt8.self, UInt8.self))
            .wrap(&vrf, keyPair) { vrf, keyPair in
                sr25519_keypair_ed25519_to_uniform(vrf.baseAddress, keyPair.baseAddress)
            }
        return vrf
    }
    
    public func vrfSign(message: Data, ifLessThan limit: Sr25519VrfThreshold) throws -> (signature: Sr25519VrfSignature, isLess: Bool) {
        var out: sr25519_vrf_out_and_proof = TCArray.new()
        let res = TCArray
            .pointer(of: (UInt8.self, UInt8.self, UInt8.self))
            .wrap(&out, vrfKeyPair, limit.threshold) { out, pair, limit in
                message.withUnsafeBytes { mes -> VrfResult in
                    let message = mes.bindMemory(to: UInt8.self)
                    return sr25519_vrf_sign_if_less(
                        out.baseAddress, pair.baseAddress, message.baseAddress,
                        UInt(message.count), limit.baseAddress
                    )
                }
            }
        guard res.result == Ok else {
            throw Sr25519Error.vrfError(code: res.result.rawValue)
        }
        return (Sr25519VrfSignature(signature: out), res.is_less)
    }
    
    public func vrfVerify(message: Data, signature: Sr25519VrfSignature, threshold: Sr25519VrfThreshold) -> Bool {
        publicKey.vrfVerify(message: message, signature: signature, threshold: threshold)
    }
}

extension Sr25519PublicKey {
    public func vrfVerify(message: Data, signature: Sr25519VrfSignature, threshold: Sr25519VrfThreshold) -> Bool {
        let res = TCArray
            .pointer(of: (UInt8.self, UInt8.self, UInt8.self, UInt8.self))
            .wrap(key, threshold.threshold, signature.output, signature.proof) { key, thr, output, proof in
                message.withUnsafeBytes { mes -> VrfResult in
                    let message = mes.bindMemory(to: UInt8.self)
                    return sr25519_vrf_verify(
                        key.baseAddress, message.baseAddress, UInt(message.count),
                        output.baseAddress, proof.baseAddress, thr.baseAddress
                    )
                }
            }
        return res.result == Ok && res.is_less
    }
}
