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
import ScaleCodecSwift
import CommonSwift
@testable import SubstrateClientSwift

class TestRuntimeMetadata: XCTestCase {
    private let bundle = Bundle(for: TestRuntimeMetadata.self)
    
    func testLocalMetadataParsing() throws {
        for network in Network.allCases {
            try parseLocalMetadata(
                for: network.localRuntimeMetadataSnapshot.localURL,
                magicNumber: network.localRuntimeMetadataSnapshot.magicNumber
            )
        }
    }
    
    func testMetadataVersion() async throws {
        for network in Network.allCases {
            try await testMetadataVersion(using: network.makeRpcClient())
        }
    }
    
    private func testMetadataVersion(using client: RpcClient) async throws {
        let response: String? = try await client.sendRequest(method: "state_getMetadata")
        guard let string = response else {
            XCTFail()
            return
        }
        
        guard let runtimeMetadata = try metadata(from: string) else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(runtimeMetadata.version, 14)
    }
    
    private func parseLocalMetadata(for url: URL?, magicNumber: UInt32) throws {
        guard let url = url else {
            XCTFail()
            return
        }
        
        let string = try String(contentsOf: url, encoding: .utf8)
        
        guard let runtimeMetadata = try metadata(from: string) else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(runtimeMetadata.magicNumber, magicNumber)
    }
    
    private func metadata(from string: String) throws -> RuntimeMetadata? {
        let encoded = try string.hex.decode()
        return try ScaleCoder.default().decoder.decode(RuntimeMetadata.self, from: encoded)
    }
    
    func testRuntimeVersion() async throws {
        for network in Network.allCases {
            let client = network.makeClient()
            let runtimeVersion = try await client.modules.systemRpc.runtimeVersion()
            XCTAssertNotNil(runtimeVersion)
        }
    }
    
    func testGenesisHash() async throws {
        for network in Network.allCases {
            let client = network.makeClient()
            let genesisHash = try await client.modules.chainRpc.blockHash(number: 0)
            XCTAssertNotNil(genesisHash)
            XCTAssertEqual(network.genesisHash, genesisHash)
        }
    }
}
