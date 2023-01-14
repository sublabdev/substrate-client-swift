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
    
    private func generatedAddMemoCases() throws -> [ExtrinsicTestCase<AddMemo>] {
        return try (0..<Constants.testsCount).compactMap { _ -> ExtrinsicTestCase<AddMemo>? in
            guard let randomIndex = (UInt32.min...UInt32.max).randomElement() else {
                XCTFail()
                return nil
            }
            
            let scaleEncodedRandomIndex = try coder.encoder.encode(randomIndex)
            let randomString = UUID().uuidString
            let scaleEncodedRandomString = try coder.encoder.encode(randomString)
            
            let addMemoPrefix = try "0x4906".hex.decode()
            guard let memo = randomString.data(using: .utf8) else {
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
    
    func testUnsignedExtrinsic() async throws {
        for `case` in try testCases() {
            try await testCase(`case`)
        }
    }
    
    private func testCase<T: Codable>(_ testCase: ExtrinsicTestCase<T>) async throws {
        let unsigned = try await client.extrinsics.makeUnsigned(
            moduleName: testCase.moduleName,
            callName: testCase.callName,
            callValue: testCase.callValue
        )
        
        XCTAssertNotNil(unsigned)
        
        let decodedUnsignedHex = try testCase.unsignedHex.hex.decode()
        let encodedUnsigned = try unsigned?.toData()
        
        if decodedUnsignedHex != encodedUnsigned {
            let expectedValue = testCase.unsignedHex
            let receivedValue = encodedUnsigned?.hex.encode(includePrefix: true)
            print("Expected to get \(expectedValue), but received: \(receivedValue)")
        }
        
        XCTAssertEqual(decodedUnsignedHex, encodedUnsigned)
    }
}
