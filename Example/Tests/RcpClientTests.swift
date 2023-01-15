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

// TODO: add async/await tests probably
class RpcClientTests: XCTestCase {
    private let network: Network = .kusama
    private lazy var client = network.makeRpcClient()
    private let expectationTimeout: TimeInterval = 10
    
    func testRpcError() {
        let expectation = XCTestExpectation()
        
        let request = RpcRequest(
            id: 0,
            method: "non_existing_method",
            params: Nothing()
        )
                
        client.send(request) { (response: RpcResponse<Nothing>?, error: RpcError?) in
            XCTAssertNil(response)
            XCTAssertNotNil(error)
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: expectationTimeout)
    }
    
    func testRpcRequests() {
        Network.allCases.forEach {
            handleSuccessRequest(using: $0.makeRpcClient())
        }
    }
    
    private func handleSuccessRequest(using client: RpcClient) {
        let method = "state_getMetadata"
        let expectation = XCTestExpectation()
        let id: Int32 = 0
        let request = RpcRequest(
            id: id,
            method: method,
            params: Nothing()
        )
        
        client.send(request) { (response: RpcResponse<String>?, error: RpcError?) in
            XCTAssertNil(error)
            XCTAssertNotNil(response)
            XCTAssertEqual(id, response?.id)
            
            expectation.fulfill()
        }
        
        client.sendRequest(method: method) { (response: String?, error: RpcError?) in
            XCTAssertNil(error)
            XCTAssertNotNil(response)
            XCTAssertEqual(response?.starts(with: "0x"), true)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 100)
    }
}
