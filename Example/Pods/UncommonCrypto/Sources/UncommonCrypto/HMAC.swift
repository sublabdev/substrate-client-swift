//
//  HMAC.swift
//  
//
//  Created by Yehor Popovych on 25.08.2021.
//

import Foundation

protocol HMACImpl {
    var outSize: Int { get }
    static var outSize: Int { get }
    
    init(key:  UnsafeBufferPointer<UInt8>)
    mutating func reset(key:  UnsafeBufferPointer<UInt8>)
    mutating func update(from: UnsafeBufferPointer<UInt8>)
    mutating func finalize(out: UnsafeMutableBufferPointer<UInt8>)
    static func authenticate(
        out: UnsafeMutableBufferPointer<UInt8>,
        key: UnsafeBufferPointer<UInt8>,
        bytes: UnsafeBufferPointer<UInt8>
    )
}

extension HMACImpl {
    var outSize: Int { Self.outSize }
}

public struct HMAC {
    private var impl: HMACImpl
    private var finalized: Bool
    
    public enum SType {
        case sha256
        case sha512
    }
    
    public init(type: SType, key: [UInt8]) {
        impl = key.withUnsafeBufferPointer {
            HMAC.implementation(for: type).init(key: $0)
        }
        finalized = false
    }
    
    public mutating func reset(key: UnsafeBufferPointer<UInt8>) {
        finalized = false
        impl.reset(key: key)
    }
    
    public mutating func update(_ bytes: [UInt8]) {
        guard !finalized else { return }
        bytes.withUnsafeBufferPointer {
            self.impl.update(from: $0)
        }
    }
    
    public mutating func update(_ data: Data) {
        guard !finalized else { return }
        data.withUnsafeBytes {
            self.impl.update(from: $0.bindMemory(to: UInt8.self))
        }
    }
    
    public mutating func finalize() -> [UInt8] {
        precondition(!finalized, "already finalized")
        finalized = true
        var out = [UInt8](repeating: 0, count: impl.outSize)
        out.withUnsafeMutableBufferPointer {
            self.impl.finalize(out: $0)
        }
        return out
    }
    
    public static func authenticate(type: SType, key: [UInt8], bytes: [UInt8]) -> [UInt8] {
        let impl = HMAC.implementation(for: type)
        var out = [UInt8](repeating: 0, count: impl.outSize)
        out.withUnsafeMutableBufferPointer { out in
            key.withUnsafeBufferPointer { key in
                bytes.withUnsafeBufferPointer { bytes in
                    impl.authenticate(out: out, key: key, bytes: bytes)
                }
            }
        }
        return out
    }
    
    public static func authenticate(type: SType, key: [UInt8], data: Data) -> [UInt8] {
        let impl = HMAC.implementation(for: type)
        var out = [UInt8](repeating: 0, count: impl.outSize)
        out.withUnsafeMutableBufferPointer { out in
            key.withUnsafeBufferPointer { key in
                data.withUnsafeBytes { data in
                    impl.authenticate(out: out, key: key, bytes: data.bindMemory(to: UInt8.self))
                }
            }
        }
        return out
    }
}

extension HMAC {
    fileprivate static func implementation(for type: SType) -> HMACImpl.Type {
        switch type {
        case .sha256: return HMAC_SHA256.self
        case .sha512: return HMAC_SHA512.self
        }
    }
}

#if canImport(CommonCrypto)
import CommonCrypto

private protocol CCHMACImpl: HMACImpl {
    var context: CCHmacContext { get set }
    
    init(context: CCHmacContext)
}

extension CCHMACImpl {
    init(key: UnsafeBufferPointer<UInt8>) {
        self.init(context: CCHmacContext())
        reset(key: key)
    }
    
    mutating func update(from: UnsafeBufferPointer<UInt8>) {
        CCHmacUpdate(&context, from.baseAddress, from.count)
    }
    
    mutating func finalize(out: UnsafeMutableBufferPointer<UInt8>) {
        CCHmacFinal(&context, out.baseAddress)
    }
}

struct HMAC_SHA256: CCHMACImpl {
    fileprivate var context: CCHmacContext
    
    mutating func reset(key:  UnsafeBufferPointer<UInt8>) {
        CCHmacInit(&context, CCHmacAlgorithm(kCCHmacAlgSHA256), key.baseAddress, key.count)
    }
    
    static func authenticate(out: UnsafeMutableBufferPointer<UInt8>, key: UnsafeBufferPointer<UInt8>, bytes: UnsafeBufferPointer<UInt8>) {
        CCHmac(CCHmacAlgorithm(kCCHmacAlgSHA256), key.baseAddress, key.count, bytes.baseAddress, bytes.count, out.baseAddress)
    }
    
    static var outSize: Int = Int(CC_SHA256_DIGEST_LENGTH)
}

struct HMAC_SHA512: CCHMACImpl {
    fileprivate var context: CCHmacContext
    
    mutating func reset(key:  UnsafeBufferPointer<UInt8>) {
        CCHmacInit(&context, CCHmacAlgorithm(kCCHmacAlgSHA512), key.baseAddress, key.count)
    }
    
    static func authenticate(out: UnsafeMutableBufferPointer<UInt8>, key: UnsafeBufferPointer<UInt8>, bytes: UnsafeBufferPointer<UInt8>) {
        CCHmac(CCHmacAlgorithm(kCCHmacAlgSHA512), key.baseAddress, key.count, bytes.baseAddress, bytes.count, out.baseAddress)
    }
    
    static var outSize: Int = Int(CC_SHA512_DIGEST_LENGTH)
}
#else
import CUncommonCrypto

struct HMAC_SHA256: HMACImpl {
    private var context: HMAC_SHA256_CTX
    
    init(key: UnsafeBufferPointer<UInt8>) {
        context = HMAC_SHA256_CTX()
        reset(key: key)
    }
    
    mutating func update(from: UnsafeBufferPointer<UInt8>) {
        hmac_sha256_Update(&context, from.baseAddress, UInt32(from.count))
    }
    
    mutating func finalize(out: UnsafeMutableBufferPointer<UInt8>) {
        hmac_sha256_Final(&context, out.baseAddress)
    }
    
    mutating func reset(key:  UnsafeBufferPointer<UInt8>) {
        hmac_sha256_Init(&context, key.baseAddress, UInt32(key.count))
    }
    
    static func authenticate(out: UnsafeMutableBufferPointer<UInt8>, key: UnsafeBufferPointer<UInt8>, bytes: UnsafeBufferPointer<UInt8>) {
        hmac_sha256(key.baseAddress, UInt32(key.count), bytes.baseAddress, UInt32(bytes.count), out.baseAddress)
    }
    
    static var outSize: Int = Int(SHA256_DIGEST_LENGTH)
}

struct HMAC_SHA512: HMACImpl {
    private var context: HMAC_SHA512_CTX
    
    init(key: UnsafeBufferPointer<UInt8>) {
        context = HMAC_SHA512_CTX()
        reset(key: key)
    }
    
    mutating func update(from: UnsafeBufferPointer<UInt8>) {
        hmac_sha512_Update(&context, from.baseAddress, UInt32(from.count))
    }
    
    mutating func finalize(out: UnsafeMutableBufferPointer<UInt8>) {
        hmac_sha512_Final(&context, out.baseAddress)
    }
    
    mutating func reset(key:  UnsafeBufferPointer<UInt8>) {
        hmac_sha512_Init(&context, key.baseAddress, UInt32(key.count))
    }
    
    static func authenticate(out: UnsafeMutableBufferPointer<UInt8>, key: UnsafeBufferPointer<UInt8>, bytes: UnsafeBufferPointer<UInt8>) {
        hmac_sha512(key.baseAddress, UInt32(key.count), bytes.baseAddress, UInt32(bytes.count), out.baseAddress)
    }
    
    static var outSize: Int = Int(SHA512_DIGEST_LENGTH)
}
#endif
