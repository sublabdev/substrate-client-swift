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
    
    func testNoRecordsAboutAccount() async throws {
        for factory in factories {
            let keyPair = try factory.generate()
            let accountId = try keyPair.publicKey.ss58.accountId()
            
            let response: Account? = try await client.storage.fetch(moduleName: "system", itemName: "account", key: accountId)
            XCTAssertNil(response) // as this is random account, no info should be present here
        }
    }
}
