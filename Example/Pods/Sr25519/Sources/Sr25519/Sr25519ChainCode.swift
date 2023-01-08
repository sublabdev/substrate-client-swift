//
//  Sr25519ChainCode.swift
//  
//
//  Created by Yehor Popovych on 25.03.2021.
//

import Foundation
#if !COCOAPODS
import CSr25519
import Sr25519Helpers
#endif

public struct Sr25519ChainCode {
    let code: sr25519_chain_code
    
    public var raw: Data {
        TCArray.get(raw: code)
    }
    
    public init(raw: Data) throws {
        guard raw.count == Self.size else {
            throw Sr25519Error.badChainCodeLength(
                length: raw.count,
                expected: Self.size
            )
        }
        self.init(code: try! TCArray.new(raw: raw))
    }
    
    init(code: sr25519_chain_code) {
        self.code = code
    }
    
    public static let size: Int = MemoryLayout<sr25519_chain_code>.size
}

extension Sr25519ChainCode: Equatable {
    public static func == (lhs: Sr25519ChainCode, rhs: Sr25519ChainCode) -> Bool {
        TCArray.equal(lhs.code, rhs.code)
    }
}

extension Sr25519ChainCode: Hashable {
    public func hash(into hasher: inout Hasher) {
        TCArray.hash(code, in: &hasher)
    }
}
