import XCTest
@testable import SubstrateClientSwift
import EncryptingSwift

class TestRandomAccount: XCTestCase {
    private let network: Network = .kusama
    private lazy var client = network.makeClient()
    
    private let factories: [KeyPairFactory] = [
        .ecdsa(kind: .substrate),
        .ecdsa(kind: .ethereum),
        .ed25519,
        .sr25519
    ]
    
    func testNoRecordsAboutAccount() throws {
        var expectations: [XCTestExpectation] = []
        
        for factory in factories {
            let keyPair = try factory.generate()
            let accountId = try keyPair.publicKey.ss58.accountId()
            let expectation = XCTestExpectation()
            expectations.append(expectation)
            
            client.storageService { storage in
                storage.fetch(moduleName: "system", itemName: "account", key: keyPair.publicKey) {
                    (response: Account?, error: RpcError?) in
                    
                    XCTAssertNil(response) // as this is random account, no info should be present here
                    XCTAssertNil(error) // should be no error, no failing request
                    expectation.fulfill()
                }
            }
        }
        
        wait(for: expectations, timeout: Constants.expectationLongTimeout)
    }
    
    private func testFailingExtrinsic(keyPair: KeyPair, accountId: Data) {
        guard let memo = "hi".data(using: .utf8) else {
            XCTFail()
            return
        }
        
        let addMemoInstruction = AddMemo(index: 0, memo: memo)
        // TODO: Need to create a signed extrinsic
    }
}
