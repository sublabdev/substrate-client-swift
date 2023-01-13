import XCTest
@testable import SubstrateClientSwift
import ScaleCodecSwift

private struct ExtrinsicTestCase<T: Codable> {
    let moduleName: String
    let callName: String
    let callValue: T
    let unsignedHex: String
}

class TestExtrinsics: XCTestCase {
    private let network: Network = .kusama
    private lazy var client = network.makeClient()
    private let coder = ScaleCoder.default()
    private var expectations: [XCTestExpectation] = []
    
    private func generatedAddMemoCases() throws -> [ExtrinsicTestCase<AddMemo>] {
        return try (0..<Constants.testsCount).compactMap { _ -> ExtrinsicTestCase<AddMemo>? in
            guard let randomIndex = (UInt32.min...UInt32.max).randomElement() else {
                XCTFail()
                return nil
            }
            
            let scaleEncodedRandomIndex = try coder.encoder.encode(randomIndex)
            let randomString = UUID().uuidString
            let scaleEncodedRandomString = try coder.encoder.encode(randomString)
            
            guard
                let addMemoPrefix = "0x4906".hex.decode(),
                let memo = randomString.data(using: .utf8)
            else {
                XCTFail()
                return nil
            }
            
            let finalHex = (
                addMemoPrefix + scaleEncodedRandomIndex + scaleEncodedRandomString
            ).hex.encode()
            
            return ExtrinsicTestCase(
                moduleName: "crowdloan",
                callName: "add_memo",
                callValue: AddMemo(index: randomIndex, memo: memo),
                unsignedHex: finalHex
            )
        }
    }
    
    private func testCases() throws -> [ExtrinsicTestCase<AddMemo>] {
        guard let memo = "hi".data(using: .utf8) else { return [] }
                
        var testCases = [
            ExtrinsicTestCase(
                moduleName: "crowdloan",
                callName: "add_memo",
                callValue: AddMemo(index: 0, memo: memo),
                unsignedHex: "0x490600000000086869"
            )
        ]
        
        try testCases.append(contentsOf: generatedAddMemoCases())
        
        return testCases
    }
    
    func testUnsignedExtrinsic() throws {
        for `case` in try testCases() {
            try testCase(`case`)
        }
        
        wait(for: expectations, timeout: Constants.expectationLongTimeout)
    }
    
    private func testCase<T: Codable>(_ testCase: ExtrinsicTestCase<T>) throws {
        let expectation = XCTestExpectation()
        expectations.append(expectation)
        
        client.extrinsicsService { [weak self] extrinsicsService in
            extrinsicsService.makeUnsigned(
                moduleName: testCase.moduleName,
                callName: testCase.callName,
                callValue: testCase.callValue
            ) { unsigned in
                XCTAssertNotNil(unsigned)
                
                do {
                    let decodedUnsignedHex = testCase.unsignedHex.hex.decode()
                    let encodedUnsigned = try self?.coder.encoder.encode(unsigned)
                    
                    if decodedUnsignedHex != encodedUnsigned {
                        let expectedValue = testCase.unsignedHex
                        let recievedValue = encodedUnsigned?.hex.encode(includePrefix: true)
                        print("Expected to get \(expectedValue), but recieved: \(recievedValue)")
                    }
                    
                    XCTAssertEqual(decodedUnsignedHex, encodedUnsigned)
                    expectation.fulfill()
                } catch let error {
                    XCTFail(error.localizedDescription)
                    expectation.fulfill()
                }
            }
        }
    }
}
