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

@testable import SubstrateClientSwift
import EncryptingSwift
import ScaleCodecSwift
import XCTest

private struct ExtrinsicTestCase<T: Codable> {
    let moduleName: String
    let callName: String
    let callValue: T
    let unsignedHex: String
}

class TestExtrinsics: XCTestCase {
    private let network: Network = .kusama
    private lazy var client = network.makeClient()
    private let codec = ScaleCoder.default()
    
    private func generatedAddMemoCases() throws -> [ExtrinsicTestCase<AddMemo>] {
        return try (0..<Constants.testsCount).compactMap { _ -> ExtrinsicTestCase<AddMemo>? in
            guard let randomIndex = (UInt32.min...UInt32.max).randomElement() else {
                XCTFail()
                return nil
            }
            
            let scaleEncodedRandomIndex = try codec.encoder.encode(randomIndex)
            let randomString = UUID().uuidString
            let scaleEncodedRandomString = try codec.encoder.encode(randomString)
            
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
        
//        try testCases.append(contentsOf: generatedAddMemoCases())
        
        return testCases
    }
    
    func test() async throws {
        for `case` in try testCases() {
            try await testCase(`case`)
        }
    }
    
    private func testCase<T: Codable>(_ testCase: ExtrinsicTestCase<T>) async throws {
        // Unsigned
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
        
        // Signed
        let keyPair = try KeyPairFactory.sr25519.generate()
        let accountId = try keyPair.publicKey.ss58.accountId()
        
        let nonce = try await client.modules.system.account(accountId: accountId)?.nonce
        XCTAssertNil(nonce)
        
        // Unwrap internal methods
        guard let extrinsics = client.extrinsics as? SubstrateExtrinsicsService else {
            XCTFail()
            return
        }
        
        let signed = try await extrinsics.makeSigned(
            moduleName: testCase.moduleName,
            callName: testCase.callName,
            callValue: testCase.callValue,
            tip: .init(value: 0),
            accountId: accountId,
            nonce: .init(value: 0),
            signatureEngine: keyPair.signatureEngine(for: keyPair.privateKey)
        )
        
        guard let signed = signed else {
            XCTFail()
            return
        }
                
        let queryFeeDetails = try await client.modules.payment.queryFeeDetails(payload: signed)
        guard let queryFeeDetails = queryFeeDetails else {
            XCTFail()
            return
        }
        
        XCTAssertGreaterThan(queryFeeDetails.baseFee.value, 0)
    }
}
