import XCTest
@testable import SubstrateClientSwift

class WebsocketTests: XCTestCase {
    // TODO: Tests
    
    // 1. Subscribe, send a message, check that the message is the same
    // 2. In Settings the default policy is 'none': send a message, subscribe after that, wait 5 sec, make sure that nothing is returned
    // 3. In Settings policy is 'firstSubscriber': send a message, subscribe with iteration 1, be sure that for that we have the same message and for other iterations we do not recieve anything
    // 4. In Settings policy is 'allSubscribers': 1000 subscriptions and all of them get the message
    // 5. In Settings policy is 'firstSubscriber': send 1000 subscriptions (from a set), subscribe, make sure that all messages are returned
    
    func testEchoClientForNone() {
        let testMessage = UUID().uuidString
        let expectationTimeOut: TimeInterval = 6
        
        let expectation = XCTestExpectation()
        let client = webSocketClientWithPolicy(.none)
        
        client?.subscribe { _ in
            // Make sure we do not recieve any message
            XCTFail()
            expectation.fulfill()
        }
        
        client?.sendMessage(.string(testMessage)) { error in
            XCTAssertNil(error)
        }
        
        // Wait for 5 seconds and fulfill the expectation
        DispatchQueue.main.asyncAfter(deadline: .now() + expectationTimeOut - 1) {
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: expectationTimeOut)
    }
    
    func testEchoClientOne() {
        let testMessage = UUID().uuidString
        let expectation = XCTestExpectation()
        let client = webSocketClientWithPolicy(.firstSubscriber)
        
        client?.subscribe { message in
            switch message {
            case .string(let string):
                XCTAssertEqual(string, testMessage)
            default:
                XCTFail()
            }
        
            expectation.fulfill()
        }
        
        client?.sendMessage(.string(testMessage), completion: { error in
            XCTAssertNil(error)
        })
        
        wait(for: [expectation], timeout: Constants.expectationShortTimeout)
    }
    
    func testEchoClientForFirstSubscriber() {
        let testMessage = UUID().uuidString
        let expectation = XCTestExpectation()
        let client = webSocketClientWithPolicy(.firstSubscriber)
        
        client?.sendMessage(.string(testMessage)) { error in
            XCTAssertNil(error)
        }
        
        // Let message be sent and received back
        
        DispatchQueue.main.asyncAfter(deadline: .now() + Constants.expectationShortTimeout) {
            for i in (0..<Constants.testsCount) {
                client?.subscribe { message in
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
        }

        wait(for: [expectation], timeout: Constants.expectationLongTimeout)
    }
    
    func testEchoClientForAllSubscribers() {
        let testMessage = UUID().uuidString
        var expectations: [Int: XCTestExpectation] = [:]
        let client = webSocketClientWithPolicy(.allSubscribers)
        
        client?.sendMessage(.string(testMessage)) { error in
            XCTAssertNil(error)
        }
        
        // Let messages be sent and received back
        
        DispatchQueue.main.asyncAfter(deadline: .now() + Constants.expectationShortTimeout) {
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
        }

        wait(for: Array(expectations.values), timeout: Constants.expectationLongTimeout)
    }
    
    // TODO: Take a look at this one
    func testEchoClientForFirstSubscriberGettingAllMessages() {
        var testMessages: Set<String> = []
//        let semaphore = DispatchSemaphore(value: 1)
        var expectations: [Int: XCTestExpectation] = [:]
        var currentSubscriberNumber = 0
        let client = webSocketClientWithPolicy(.firstSubscriber)
        
        for i in (0..<20) {
            let testMessage = UUID().uuidString
            testMessages.insert(testMessage)
            expectations[i] = XCTestExpectation()
            
            client?.sendMessage(.string(testMessage)) { error in
                XCTAssertNil(error)
            }
        }
        
        // Let messages be sent and received back
        
        DispatchQueue.main.asyncAfter(deadline: .now() + Constants.expectationShortTimeout) {
            client?.subscribe { message in
    //            semaphore.wait()
                print("currentSubscriberNumber: ", currentSubscriberNumber)
                switch message {
                case .string(let string):
                    XCTAssertTrue(testMessages.contains(string))
                default:
                    XCTFail()
                }
            
                expectations[currentSubscriberNumber]?.fulfill()
                currentSubscriberNumber += 1
    //            semaphore.signal()
            }
            
            client?.subscribe { _ in
                // Shouldn't recieve anything
                XCTFail()
            }
        }
        
        wait(for: Array(expectations.values), timeout: 100)
    }
    
    private func webSocketClientWithPolicy(_ policy: WebSocketClientSettings.Policy) -> WebSocketClientProtocol? {
        guard let host = URL(string: Constants.webSocketUrl) else {
            XCTFail()
            return nil
        }
        
        return WebSocketClient(
            host: host,
            port: Constants.webSocketPort,
            settings: .init(policy: policy)
        )
    }
}
