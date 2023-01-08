//
//  SHA3.swift
//  
//
//  Created by Yehor Popovych on 20.05.2021.
//

import Foundation
#if !COCOAPODS
import CUncommonCrypto
#endif

public struct SHA3 {
    public enum SType {
        case sha224
        case sha256
        case sha384
        case sha512
        case keccak224
        case keccak256
        case keccak384
        case keccak512
    }
    
    private var context: SHA3_CTX
    private let type: SType
    private var finalized: Bool
    
    public init(type: SType) {
        self.type = type
        self.context = SHA3_CTX()
        self.finalized = true
        reset()
    }
    
    public mutating func reset() {
        finalized = false
        switch type {
        case .keccak224, .sha224: sha3_224_Init(&context)
        case .keccak256, .sha256: sha3_256_Init(&context)
        case .keccak384, .sha384: sha3_384_Init(&context)
        case .keccak512, .sha512: sha3_512_Init(&context)
        }
    }
    
    public mutating func update(_ bytes: [UInt8]) {
        bytes.withUnsafeBufferPointer {
            self._update(bytes: $0)
        }
    }
    
    public mutating func update(_ data: Data) {
        data.withUnsafeBytes {
            self._update(bytes: $0.bindMemory(to: UInt8.self))
        }
    }
    
    public mutating func finalize() -> [UInt8] {
        precondition(!finalized, "already finalized")
        finalized = true
        var out = [UInt8](repeating: 0, count: type.outSize)
        if type.isKeccak {
            keccak_Final(&context, &out)
        } else {
            sha3_Final(&context, &out)
        }
        return out
    }
    
    public static func hash(type: SType, bytes: [UInt8]) -> [UInt8] {
        return bytes.withUnsafeBufferPointer {
            Self._hash(type: type, bytes: $0)
        }
    }
    
    public static func hash(type: SType, data: Data) -> [UInt8] {
        return data.withUnsafeBytes {
            Self._hash(type: type, bytes: $0.bindMemory(to: UInt8.self))
        }
    }
    
    private mutating func _update(bytes: UnsafeBufferPointer<UInt8>) {
        guard !finalized else { return }
        sha3_Update(&context, bytes.baseAddress, bytes.count)
    }
    
    private static func _hash(type: SType, bytes: UnsafeBufferPointer<UInt8>) -> [UInt8] {
        switch type {
        case .keccak256:
            var out = [UInt8](repeating: 0, count: type.outSize)
            keccak_256(bytes.baseAddress, bytes.count, &out)
            return out
        case .sha256:
            var out = [UInt8](repeating: 0, count: type.outSize)
            sha3_256(bytes.baseAddress, bytes.count, &out)
            return out
        case .keccak512:
            var out = [UInt8](repeating: 0, count: type.outSize)
            keccak_512(bytes.baseAddress, bytes.count, &out)
            return out
        case .sha512:
            var out = [UInt8](repeating: 0, count: type.outSize)
            sha3_512(bytes.baseAddress, bytes.count, &out)
            return out
        default:
            var sha3 = SHA3(type: type)
            sha3._update(bytes: bytes)
            return sha3.finalize()
        }
    }
}


extension SHA3.SType {
    var outSize: Int {
        switch self {
        case .sha224, .keccak224: return Int(SHA3_224_DIGEST_LENGTH)
        case .sha256, .keccak256: return Int(SHA3_256_DIGEST_LENGTH)
        case .sha384, .keccak384: return Int(SHA3_384_DIGEST_LENGTH)
        case .sha512, .keccak512: return Int(SHA3_512_DIGEST_LENGTH)
        }
    }
    
    var bits: Int { outSize * 8 }
    
    var isKeccak: Bool {
        switch self {
        case .keccak224, .keccak256, .keccak384, .keccak512:
            return true
        default:
            return false
        }
    }
}
