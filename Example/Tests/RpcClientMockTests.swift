import XCTest
@testable import SubstrateClientSwift

class RpcClientMockTests: XCTestCase {
    private var client: RpcClient?
    private let url = URL(string: Constants.kusamaUrl)
    private let expectationTimeOut: TimeInterval = 1
    
    private lazy var httpURLResponse: HTTPURLResponse? = url.flatMap {
        HTTPURLResponse(
            url: $0,
            statusCode: 200,
            httpVersion: nil,
            headerFields: ["Content-Type": "application/json"]
        )
    }
    
    override func setUp() {
        guard let url = url else {
            XCTFail()
            return
        }
        
        let configuration = URLSessionConfiguration.default
        configuration.protocolClasses = [MockURLProtocol.self]
        
        let urlSession = URLSession(configuration: configuration)
        client = RpcClient(url: url, session: urlSession)
    }
    
    override func tearDown() {
        client = nil
    }
    
    func testRpcErrorWhenWrongDataReturned() {
        let expectation = XCTestExpectation()
        setMockUrlProtocolRequestHandler(data: Data(), response: httpURLResponse)
        sendFailingRequest(
            RpcRequest(id: 1, method: "non_existing_method", params: Nothing()),
            expecting: expectation
        )
        
        wait(for: [expectation], timeout: expectationTimeOut)
    }
    
    func testRpcErrorWhenDataNotReturned() {
        let expectation = XCTestExpectation()
        setMockUrlProtocolRequestHandler(data: nil, response: httpURLResponse)
        sendFailingRequest(RpcRequest(id: 1, method: "non_existing_method", params: Nothing()), expecting: expectation)
        
        wait(for: [expectation], timeout: expectationTimeOut)
    }
    
    func testRpcRequestSuccess() {
        guard let client = client else {
            XCTFail()
            return
        }
        
        let expectation = XCTestExpectation()
        let requestId = Int64.random(in: Int64.min..<Int64.max)
        let request = RpcRequest(id: requestId, method: "state_getMetadata", params: Nothing())
        
        let responseResult: Data? = "Response data".data(using: .utf8)
        let successResponse = RpcResponse(jsonrpc: "2.0", id: requestId, result: responseResult)
        var responseData: Data?
        
        do {
            responseData = try JSONEncoder().encode(successResponse)
        } catch let error {
            XCTFail("\(error.localizedDescription)")
        }
        
        guard let responseData = responseData else {
            XCTFail()
            return
        }
        
        setMockUrlProtocolRequestHandler(data: responseData, response: httpURLResponse)
        
        client.send(request) { (response: RpcResponse<Data>?, error: RpcError?) in
            XCTAssertNil(error)
            XCTAssertNotNil(response)
            XCTAssertEqual(requestId, response?.id)
            XCTAssertEqual(responseResult, response?.result)
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: expectationTimeOut)
    }
    
    // MARK: - Private
    
    private func sendFailingRequest<T: Codable>(_ request: RpcRequest<T>, expecting expectation: XCTestExpectation) {
        guard let client = client else {
            XCTFail()
            return
        }
        
        client.send(request) { (response: RpcResponse<Data>?, error: RpcError?) in
            XCTAssertNotNil(error)
            expectation.fulfill()
        }
    }
    
    private func setMockUrlProtocolRequestHandler(data: Data?, response: HTTPURLResponse?) {
        guard let response = response else {
            XCTFail()
            return
        }
        
        MockURLProtocol.requestHandler = { _ in (response, data) }
    }
}
