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

import XCTest
@testable import SubstrateClientSwift
import EncryptingSwift

class TestRandomAccount: XCTestCase {
    private let network: Network = .kusama
    private lazy var client = network.makeClient()
    
    private let factories: [KeyPairFactory] = [
        .ecdsa(kind: .substrate),
        .ecdsa(kind: .ethereum),
        .ed25519,
        .sr25519
    ]
    
    func testNoRecordsAboutAccount() async throws {
        for factory in factories {
            let keyPair = try factory.generate()
            let accountId = try keyPair.publicKey.ss58.accountId()
            
            let response: Account? = try await client.storage.fetch(moduleName: "system", itemName: "account", key: accountId)
            XCTAssertNil(response) // as this is random account, no info should be present here
        }
    }
}
