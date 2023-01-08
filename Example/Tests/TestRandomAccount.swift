import XCTest
@testable import SubstrateClientSwift
import EncryptingSwift

class TestRandomAccount: XCTestCase {
    private let network: Endpoint = .kusama
    private let factories: [KeyPairFactory] = [
        .ecdsa,
        .ed25519,
        .sr25519
    ]
    
    private lazy var client: SubstrateClient? = {
        guard let url = URL(string: network.endpointInfo.url) else {
            XCTFail()
            return nil
        }
        
        return SubstrateClient(url: url)
    }()
    
    func noRecordsAboutAccount() throws {
        var expectations: [XCTestExpectation] = []
        
        for factory in factories {
            // TODO: Figure out what should be here as a seed
            let keyPair = try factory.load(seed: Data())
            let accountId = try keyPair.publicKey.ss58.accountId()
            let expectation = XCTestExpectation()
            expectations.append(expectation)
            
            client?.storageService { storage in
                storage.fetch(moduleName: "system", itemName: "account") { (response: Account?, error: RpcError?) in
                    XCTAssertNil(response)
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
