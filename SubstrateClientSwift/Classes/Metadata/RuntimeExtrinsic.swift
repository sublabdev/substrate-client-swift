/**
 *
 * Copyright 2023 SUBSTRATE LABORATORY LLC <info@sublab.dev>
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0

 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 * 
 */

import Foundation
import BigInt

/// Runtime extrinsic. Contains its type, version and an array of signed extensions
public final class RuntimeExtrinsic: Codable {
    public let type: BigUInt
    public let version: UInt8
    public let signedExtensions: [SignedExtension]
    
    public init(type: BigUInt, version: UInt8, signedExtensions: [SignedExtension]) {
        self.type = type
        self.version = version
        self.signedExtensions = signedExtensions
    }
    
    /// Signed extension for a runtime extrinsic
    public final class SignedExtension: Codable {
        public let identifier: String
        public let type: BigUInt
        public let additionalSigned: BigUInt
        
        public init(identifier: String, type: BigUInt, additionalSigned: BigUInt) {
            self.identifier = identifier
            self.type = type
            self.additionalSigned = additionalSigned
        }
    }
}
