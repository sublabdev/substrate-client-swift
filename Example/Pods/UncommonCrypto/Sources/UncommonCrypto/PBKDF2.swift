//
//  PBKDF2.swift
//
//
//  Created by Yehor Popovych on 10.05.2021.
//

import Foundation

public struct PBKDF2 {
    public enum HmacType {
        case sha256
        case sha512
    }
    
    public struct Error: Swift.Error {
        public let code: Int
    }
    
    public static func derive(type: HmacType, password: [UInt8], salt: [UInt8], iterations: Int = 2048, keyLength: Int = 64) throws -> [UInt8] {
        try _derive(type, password: password, salt: salt,
                    iterations: iterations, keyLength: keyLength)
    }
}

#if canImport(CommonCrypto)
import CommonCrypto

extension PBKDF2.HmacType {
    var native: CCPBKDFAlgorithm {
        switch self {
        case .sha256: return CCPBKDFAlgorithm(kCCPRFHmacAlgSHA256)
        case .sha512: return CCPBKDFAlgorithm(kCCPRFHmacAlgSHA512)
        }
    }
}

extension PBKDF2 {
    fileprivate static func _derive(_ type: HmacType, password: [UInt8], salt: [UInt8], iterations: Int = 2048, keyLength: Int = 64) throws -> [UInt8] {
        var bytes = [UInt8](repeating: 0, count: keyLength)

        let status: Int32 = password.withUnsafeBytes { pptr in
            let passwdPtr = pptr.bindMemory(to: CChar.self)
            return CCKeyDerivationPBKDF(
                CCPBKDFAlgorithm(kCCPBKDF2),
                passwdPtr.baseAddress,
                passwdPtr.count,
                salt,
                salt.count,
                type.native,
                UInt32(iterations),
                &bytes,
                keyLength
            )
        }

        guard status == kCCSuccess else {
            throw Error(code: Int(status))
        }
        return bytes
    }
}
#else
import CUncommonCrypto

extension PBKDF2 {
    fileprivate static func _derive(_ type: HmacType, password: [UInt8], salt: [UInt8], iterations: Int = 2048, keyLength: Int = 64) throws -> [UInt8] {
        var key = [UInt8](repeating: 0, count: keyLength)
        switch type {
        case .sha256:
            pbkdf2_hmac_sha256(password, Int32(password.count), salt, Int32(salt.count), UInt32(iterations), &key, Int32(keyLength))
        case .sha512:
            pbkdf2_hmac_sha512(password, Int32(password.count), salt, Int32(salt.count), UInt32(iterations), &key, Int32(keyLength))
            
        }
        return key
    }
}
#endif
