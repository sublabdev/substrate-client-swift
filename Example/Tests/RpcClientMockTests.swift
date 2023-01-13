import XCTest
@testable import SubstrateClientSwift

class RpcClientMockTests: XCTestCase {
    private let network: Network = .kusama
    private lazy var client = network.makeRpcClient()
    
//    override func setUp() {
//        let configuration = URLSessionConfiguration.default
//        configuration.protocolClasses = [MockURLProtocol.self]
//
//        let urlSession = URLSession(configuration: configuration)
//        client = network.makeRpcClient(urlSession: urlSession)
//    }
    
    func testRpcError() {
        let expectation = XCTestExpectation()
        
        let request = RpcRequest(id: 1, method: "non_existing_method", params: Nothing())
        client.send(request) { (response: RpcResponse<Nothing>?, error: RpcError?) in
            
            XCTAssertNotNil(error)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: Constants.expectationLongTimeout)
    }
    
    func testRpcSuccess() throws {
        let expectation = XCTestExpectation()
        let requestId = Int32.random(in: Int32.min..<Int32.max) // TODO: refactor to incremental
        let request = RpcRequest(id: requestId, method: "state_getMetadata", params: Nothing())
        
        client.send(request) { (response: RpcResponse<String>?, error: RpcError?) in
            XCTAssertNil(error)
            
            XCTAssertEqual(requestId, response?.id)
            guard let result = response?.result else {
                XCTFail()
                return
            }
            
            XCTAssertFalse(result.isEmpty)
            XCTAssertTrue(result.starts(with: "0x"))
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: Constants.expectationLongTimeout)
    }
}
