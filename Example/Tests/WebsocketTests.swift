import XCTest
@testable import SubstrateClientSwift
import Combine

class WebsocketTests: XCTestCase {
    private var cancellableSubscriptions = Set<AnyCancellable>()
    
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
        
        client?.subscribe { [weak self] subject in
            guard let `self` = self else { return }
            
            subject?
                .sink { _ in
                    // Make sure we do not recieve any messages
                    XCTFail()
                    expectation.fulfill()
                }
                .store(in: &self.cancellableSubscriptions)
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
        
        client?.subscribe { [weak self] subject in
            guard let `self` = self else { return }
            
            subject?
                .sink { message in
                    switch message {
                    case .string(let string):
                        XCTAssertEqual(string, testMessage)
                    default:
                        XCTFail()
                    }
                    
                    expectation.fulfill()
                }
                .store(in: &self.cancellableSubscriptions)
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
            client?.subscribe { [weak self] subject in
                guard let `self` = self else { return }
                
                subject?
                    .sink { message in
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
                    .store(in: &self.cancellableSubscriptions)
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
            
            client?.subscribe { [weak self] subject in
                guard let `self` = self else { return }
                
                subject?
                    .sink { message in
                        switch message {
                        case .string(let string):
                            XCTAssertEqual(string, testMessage)
                        default:
                            XCTFail()
                        }
                        
                        expectations[i]?.fulfill()
                    }
                    .store(in: &self.cancellableSubscriptions)
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
        
        client?.subscribe { [weak self] subject in
            guard let `self` = self else { return }
            
            subject?
                .sink{ message in
                    switch message {
                    case .string(let string):
                        XCTAssertTrue(testMessages.contains(string))
                        testMessages.remove(string)
                        expectations[string]?.fulfill()
                    default:
                        XCTFail()
                    }
                }
                .store(in: &self.cancellableSubscriptions)
        }
        
        // Double check if all messages were received
        XCTAssertTrue(testMessages.isEmpty)
        
        client?.subscribe { [weak self] subject in
            guard let `self` = self else { return }
            
            subject?.sink { _ in
                // Shouldn't receive anything
                XCTFail()
            }
            .store(in: &self.cancellableSubscriptions)
        }

        wait(for: Array(expectations.values), timeout: 1000)
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
    
    private func sleepFor(timeInterval: TimeInterval) {
        sleep(UInt32(timeInterval))
    }
}
