//
//  Random.swift
//  
//
//  Created by Yehor Popovych on 07.05.2021.
//

import Foundation
#if !COCOAPODS
import CSr25519
#endif

public struct Sr25519SecureRandom {
    public static func bytes(count: Int) -> [UInt8] {
        var bytes = [UInt8](repeating: 0, count: count)
        sr25519_randombytes(&bytes, count)
        return bytes
    }
}
