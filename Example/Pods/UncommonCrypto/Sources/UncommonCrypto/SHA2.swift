//
//  SHA2.swift
//  
//
//  Created by Yehor Popovych on 20.05.2021.
//

import Foundation

protocol SHA2Impl {
    var outSize: Int { get }
    static var outSize: Int { get }
    
    init()
    mutating func reset()
    mutating func update(from: UnsafeBufferPointer<UInt8>)
    mutating func finalize(out: UnsafeMutableBufferPointer<UInt8>)
    static func hash(
        out: UnsafeMutableBufferPointer<UInt8>,
        bytes: UnsafeBufferPointer<UInt8>
    )
}

extension SHA2Impl {
    var outSize: Int { Self.outSize }
}

public struct SHA2 {
    private var impl: SHA2Impl
    private var finalized: Bool
    
    public enum SType {
        case sha256
        case sha512
    }
    
    public init(type: SType) {
        impl = SHA2.implementation(for: type).init()
        finalized = false
    }
    
    public mutating func reset() {
        finalized = false
        impl.reset()
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
    
    public static func hash(type: SType, bytes: [UInt8]) -> [UInt8] {
        let impl = SHA2.implementation(for: type)
        var out = [UInt8](repeating: 0, count: impl.outSize)
        out.withUnsafeMutableBufferPointer { out in
            bytes.withUnsafeBufferPointer { bytes in
                impl.hash(out: out, bytes: bytes)
            }
        }
        return out
    }
    
    public static func hash(type: SType, data: Data) -> [UInt8] {
        let impl = SHA2.implementation(for: type)
        var out = [UInt8](repeating: 0, count: impl.outSize)
        out.withUnsafeMutableBufferPointer { out in
            data.withUnsafeBytes { data in
                impl.hash(out: out, bytes: data.bindMemory(to: UInt8.self))
            }
        }
        return out
    }
}

extension SHA2 {
    fileprivate static func implementation(for type: SType) -> SHA2Impl.Type {
        switch type {
        case .sha256: return SHA2_256.self
        case .sha512: return SHA2_512.self
        }
    }
}

#if canImport(CommonCrypto)
import CommonCrypto

struct SHA2_256: SHA2Impl {
    private var context: CC_SHA256_CTX
    
    init() {
        context = CC_SHA256_CTX()
        reset()
    }
    
    mutating func reset() {
        let res = CC_SHA256_Init(&context)
        precondition(res == 1, "init failed")
    }
    
    mutating func update(from: UnsafeBufferPointer<UInt8>) {
        let res = CC_SHA256_Update(&context, from.baseAddress, CC_LONG(from.count))
        precondition(res == 1, "update failed")
    }
    
    mutating func finalize(out: UnsafeMutableBufferPointer<UInt8>) {
        let res = CC_SHA256_Final(out.baseAddress, &context)
        precondition(res == 1, "finalization failed")
    }
    
    static func hash(out: UnsafeMutableBufferPointer<UInt8>, bytes: UnsafeBufferPointer<UInt8>) {
        CC_SHA256(bytes.baseAddress, CC_LONG(bytes.count), out.baseAddress)
    }
    
    static var outSize: Int = Int(CC_SHA256_DIGEST_LENGTH)
}

struct SHA2_512: SHA2Impl {
    private var context: CC_SHA512_CTX
    
    init() {
        context = CC_SHA512_CTX()
        reset()
    }
    
    mutating func reset() {
        let res = CC_SHA512_Init(&context)
        precondition(res == 1, "init failed")
    }
    
    mutating func update(from: UnsafeBufferPointer<UInt8>) {
        let res = CC_SHA512_Update(&context, from.baseAddress, CC_LONG(from.count))
        precondition(res == 1, "update failed")
    }
    
    mutating func finalize(out: UnsafeMutableBufferPointer<UInt8>) {
        let res = CC_SHA512_Final(out.baseAddress, &context)
        precondition(res == 1, "finalization failed")
    }
    
    static func hash(out: UnsafeMutableBufferPointer<UInt8>, bytes: UnsafeBufferPointer<UInt8>) {
        CC_SHA512(bytes.baseAddress, CC_LONG(bytes.count), out.baseAddress)
    }
    
    static var outSize: Int = Int(CC_SHA512_DIGEST_LENGTH)
}
#else
import CUncommonCrypto

struct SHA2_256: SHA2Impl {
    private var context: SHA256_CTX
    
    init() {
        context = SHA256_CTX()
        reset()
    }
    
    mutating func reset() {
        sha256_Init(&context)
    }
    
    mutating func update(from: UnsafeBufferPointer<UInt8>) {
        sha256_Update(&context, from.baseAddress, from.count)
    }
    
    mutating func finalize(out: UnsafeMutableBufferPointer<UInt8>) {
        sha256_Final(&context, out.baseAddress)
    }
    
    static func hash(out: UnsafeMutableBufferPointer<UInt8>, bytes: UnsafeBufferPointer<UInt8>) {
        sha256_Raw(bytes.baseAddress, bytes.count, out.baseAddress)
    }
    
    static var outSize: Int = Int(SHA256_DIGEST_LENGTH)
}

struct SHA2_512: SHA2Impl {
    private var context: SHA512_CTX
    
    init() {
        context = SHA512_CTX()
        reset()
    }
    
    mutating func reset() {
        sha512_Init(&context)
    }
    
    mutating func update(from: UnsafeBufferPointer<UInt8>) {
        sha512_Update(&context, from.baseAddress, from.count)
    }
    
    mutating func finalize(out: UnsafeMutableBufferPointer<UInt8>) {
        sha512_Final(&context, out.baseAddress)
    }
    
    static func hash(out: UnsafeMutableBufferPointer<UInt8>, bytes: UnsafeBufferPointer<UInt8>) {
        sha512_Raw(bytes.baseAddress, bytes.count, out.baseAddress)
    }
    
    static var outSize: Int = Int(SHA512_DIGEST_LENGTH)
}
#endif

extension Data {
    public var sha256: [UInt8] { SHA2.hash(type: .sha256, data: self) }
    public var sha512: [UInt8] { SHA2.hash(type: .sha512, data: self) }
}


extension Array where Element == UInt8 {
    public var sha256: [UInt8] { SHA2.hash(type: .sha256, bytes: self) }
    public var sha512: [UInt8] { SHA2.hash(type: .sha512, bytes: self) }
}
