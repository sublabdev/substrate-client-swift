import XCTest
@testable import SubstrateClientSwift

class RpcClientTests: XCTestCase {
    private let expectationTimeout: TimeInterval = 10
    
    func testRpcError() {
        guard let url = URL(string: Constants.kusamaUrl) else {
            XCTFail()
            return
        }
        
        let expectation = XCTestExpectation()
        
        let request = RpcRequest(
            id: 0,
            method: "non_existing_method",
            params: Nothing()
        )
        
        let client = RpcClient(url: url)
        
        client.send(request) { (response: RpcResponse<Nothing>?, error: RpcError?) in
            XCTAssertNil(response)
            XCTAssertNotNil(error)
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: expectationTimeout)
    }
    
    func testRpcRequestForKusama() {
        guard let url = URL(string: Constants.kusamaUrl) else {
            XCTFail()
            return
        }
        
        handleSuccessRequestForUrl(url)
    }
    
    func testRpcRequestForPolkadot() {
        guard let url = URL(string: Constants.polkadotUrl) else {
            XCTFail()
            return
        }
        
        handleSuccessRequestForUrl(url)
    }
    
    func testRpcRequestForWestend() {
        guard let url = URL(string: Constants.westendUrl) else {
            XCTFail()
            return
        }
        
        handleSuccessRequestForUrl(url)
    }
    
    private func handleSuccessRequestForUrl(_ url: URL) {
        let method = "state_getMetadata"
        let expectation = XCTestExpectation()
        let id: Int64 = 0
        let request = RpcRequest(
            id: id,
            method: method,
            params: Nothing()
        )
        
        let client = RpcClient(url: url)
        
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
