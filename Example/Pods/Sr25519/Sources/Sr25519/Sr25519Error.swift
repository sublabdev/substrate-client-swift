//
//  Sr25519Error.swift
//  
//
//  Created by Yehor Popovych on 25.03.2021.
//

import Foundation

public enum Sr25519Error: Error, Equatable, Hashable {
    case badSeedLength(length: Int, expected: Int)
    case badKeyPairLength(length: Int, expected: Int)
    case badChainCodeLength(length: Int, expected: Int)
    case badPublicKeyLength(length: Int, expected: Int)
    case badSignatureLength(length: Int, expected: Int)
    case badVrfSignatureLength(length: Int, expected: Int)
    case badVrfThresholdLength(length: Int, expected: Int)
    case vrfError(code: UInt32)
}
