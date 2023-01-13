import XCTest
@testable import SubstrateClientSwift

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
