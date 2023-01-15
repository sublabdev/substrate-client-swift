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

class WebsocketTests: XCTestCase {
    func testEchoClientForNone() {
        let testMessage = UUID().uuidString
        let expectationTimeOut: TimeInterval = 5
        
        let expectation = XCTestExpectation()
        let client = webSocketClientWithPolicy(.none)
        
        client?.sendMessage(.string(testMessage)) { error in
            XCTAssertNil(error)
        }
        
        // Wait for 5 seconds and fulfill the expectation
        sleepFor(timeInterval: expectationTimeOut - 1)
        
        client?.subscribe { _ in
            // Make sure we do not recieve any messages
            XCTFail()
            expectation.fulfill()
        }

        expectation.fulfill()
        wait(for: [expectation], timeout: expectationTimeOut)
    }
    
    func testEchoClientOne() {
        let testMessage = UUID().uuidString
        let expectation = XCTestExpectation()
        let client = webSocketClientWithPolicy(.firstSubscriber)
        
        client?.sendMessage(.string(testMessage), completion: { error in
            XCTAssertNil(error)
        })
        
        client?.subscribe { message in
            switch message {
            case .string(let string):
                XCTAssertEqual(string, testMessage)
            default:
                XCTFail()
            }
            
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: Constants.singleTestTime)
    }

    func testEchoClientFirstSubscriber() {
        let testMessage = UUID().uuidString
        let expectation = XCTestExpectation()
        let client = webSocketClientWithPolicy(.firstSubscriber)
        
        client?.sendMessage(.string(testMessage)) { error in
            XCTAssertNil(error)
        }
        
        // Let message be sent and received back
        sleepFor(timeInterval: Constants.singleTestTime)
        
        for i in (0..<Constants.testsCount) {
            client?.subscribe{ message in
                guard i == 0 else {
                    // Do not expect to get a message for other subscibers except the first one
                    XCTFail()
                    return
                }
                
                switch message {
                case .string(let string):
                    XCTAssertEqual(string, testMessage)
                default:
                    XCTFail()
                }
                
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: Constants.expectationLongTimeout)
    }

    func testEchoClientAllSubscribers() {
        let testMessage = UUID().uuidString
        var expectations: [Int: XCTestExpectation] = [:]
        let client = webSocketClientWithPolicy(.allSubscribers)

        client?.sendMessage(.string(testMessage)) { error in
            XCTAssertNil(error)
        }

        // Let messages be sent and received back
        sleepFor(timeInterval: Constants.singleTestTime)
        
        for i in (0..<Constants.testsCount) {
            expectations[i] = XCTestExpectation()
            
            client?.subscribe { message in
                switch message {
                case .string(let string):
                    XCTAssertEqual(string, testMessage)
                default:
                    XCTFail()
                }
                
                expectations[i]?.fulfill()
            }
        }
        
        wait(for: Array(expectations.values), timeout: Constants.expectationLongTimeout)
    }

    func testEchoClientFirstSubscriberGettingAllMessages() {
        var testMessages: Set<String> = []
        var expectations: [String: XCTestExpectation] = [:]
        let client = webSocketClientWithPolicy(.firstSubscriber)

        for _ in (0..<Constants.testsCount) {
            let testMessage = UUID().uuidString
            testMessages.insert(testMessage)
            expectations[testMessage] = XCTestExpectation()

            client?.sendMessage(.string(testMessage)) { error in
                XCTAssertNil(error)
            }
        }

        // Let messages be sent and received back
        sleepFor(timeInterval: Constants.singleTestTime)
        
        client?.subscribe { message in
            switch message {
            case .string(let string):
                XCTAssertTrue(testMessages.contains(string))
                testMessages.remove(string)
                expectations[string]?.fulfill()
            default:
                XCTFail()
            }
        }
        
        // Double check if all messages were received
        XCTAssertTrue(testMessages.isEmpty)
        
        client?.subscribe { _ in
            // Shouldn't receive anything
            XCTFail()
        }

        wait(for: Array(expectations.values), timeout: 1000)
    }
    
    private func webSocketClientWithPolicy(_ policy: WebSocketClientSubscriptionPolicy) -> WebSocketClientProtocol? {
        WebSocketClient(
            host: Constants.webSocketUrl,
            port: Constants.webSocketPort,
            policy: policy
        )
    }
    
    private func sleepFor(timeInterval: TimeInterval) {
        sleep(UInt32(timeInterval))
    }
}
