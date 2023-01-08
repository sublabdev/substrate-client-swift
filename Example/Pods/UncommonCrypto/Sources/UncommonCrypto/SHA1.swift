//
//  SHA1.swift
//  
//
//  Created by Yehor Popovych on 20.05.2021.
//

import Foundation

#if canImport(CommonCrypto)
import CommonCrypto

public struct SHA1 {
    private var context: CC_SHA1_CTX
    private var finalized: Bool
    
    public init() {
        context = CC_SHA1_CTX()
        finalized = true
        reset()
    }
    
    public mutating func update(_ bytes: [UInt8]) {
        guard !finalized else { return }
        let res = CC_SHA1_Update(&context, bytes, CC_LONG(bytes.count))
        precondition(res == 1, "update failed")
    }
    
    public mutating func update(_ data: Data) {
        guard !finalized else { return }
        let res: Int32 = data.withUnsafeBytes { ptr in
            let bPtr = ptr.bindMemory(to: UInt8.self)
            return CC_SHA1_Update(&self.context, bPtr.baseAddress, CC_LONG(bPtr.count))
        }
        precondition(res == 1, "update failed")
    }
    
    public mutating func finalize() -> [UInt8] {
        precondition(!finalized, "already finalized")
        finalized = true
        var out = [UInt8](repeating: 0, count: Int(CC_SHA1_DIGEST_LENGTH))
        let res = CC_SHA1_Final(&out, &context)
        precondition(res == 1, "finalize failed")
        return out
    }
    
    public mutating func reset() {
        finalized = false
        let res = CC_SHA1_Init(&context)
        precondition(res == 1, "init failed")
    }
    
    public static func hash(bytes: [UInt8]) -> [UInt8] {
        var out = [UInt8](repeating: 0, count: Int(CC_SHA1_DIGEST_LENGTH))
        CC_SHA1(bytes, CC_LONG(bytes.count), &out)
        return out
    }
    
    public static func hash(data: Data) -> [UInt8] {
        var out = [UInt8](repeating: 0, count: Int(CC_SHA1_DIGEST_LENGTH))
        data.withUnsafeBytes {
            let ptr = $0.bindMemory(to: UInt8.self)
            CC_SHA1(ptr.baseAddress, CC_LONG(ptr.count), &out)
        }
        return out
    }
}
#else
import CUncommonCrypto

public struct SHA1 {
    private var context: SHA1_CTX
    private var finalized: Bool
    
    public init() {
        context = SHA1_CTX()
        finalized = true
        reset()
    }
    
    public mutating func update(_ bytes: [UInt8]) {
        guard !finalized else { return }
        sha1_Update(&context, bytes, bytes.count)
    }
    
    public mutating func update(_ data: Data) {
        guard !finalized else { return }
        data.withUnsafeBytes { ptr in
            let bPtr = ptr.bindMemory(to: UInt8.self)
            sha1_Update(&self.context, bPtr.baseAddress, bPtr.count)
        }
    }
    
    public mutating func finalize() -> [UInt8] {
        precondition(!finalized, "already finalized")
        finalized = true
        var out = [UInt8](repeating: 0, count: Int(SHA1_DIGEST_LENGTH))
        sha1_Final(&context, &out)
        return out
    }
    
    public mutating func reset() {
        sha1_Init(&context)
        finalized = false
    }
    
    public static func hash(bytes: [UInt8]) -> [UInt8] {
        var out = [UInt8](repeating: 0, count: Int(SHA1_DIGEST_LENGTH))
        sha1_Raw(bytes, bytes.count, &out)
        return out
    }
    
    public static func hash(data: Data) -> [UInt8] {
        var out = [UInt8](repeating: 0, count: Int(SHA1_DIGEST_LENGTH))
        data.withUnsafeBytes {
            let ptr = $0.bindMemory(to: UInt8.self)
            sha1_Raw(ptr.baseAddress, ptr.count, &out)
        }
        return out
    }
}
#endif

extension Data {
    public var sha1: [UInt8] { SHA1.hash(data: self) }
}


extension Array where Element == UInt8 {
    public var sha1: [UInt8] { SHA1.hash(bytes: self) }
}
