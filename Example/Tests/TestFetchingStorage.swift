import XCTest
@testable import SubstrateClientSwift
import BigInt
import Combine

struct RpcStorageItem<T> {
    let module: String
    let item: String
    let keys: [Data]
    private var validation: ((T) -> Bool)? = nil
    
    init(module: String, item: String, keys: [Data] = [], validation: ((T) -> Bool)? = nil) {
        self.module = module
        self.item = item
        self.keys = keys
        self.validation = validation
    }
    
    func validate(value: T) -> Bool? {
        validation?(value)
    }
}

class TestFetchingStorage: XCTestCase {
    private var anyCancellables = Set<AnyCancellable>()
    private let network: Endpoint = .kusama
    private lazy var client: SubstrateClient? = {
        guard let url = URL(string: network.endpointInfo.url) else { return nil }
        return SubstrateClient(url: url)
    }()
    
    private var storageItem: RpcStorageItem<UInt64> {
        .init(module: "timestamp", item: "now") {
            // Difference should be within one minute, let's assume some big lag
            let date1 = Date().timeIntervalSinceReferenceDate
            let date2 = Date(timeIntervalSinceNow: TimeInterval($0)).timeIntervalSinceReferenceDate
            return (date1 - date2) < Constants.expectationLongTimeout
        }
    }
    
    private var storageItemAccount: RpcStorageItem<Account> {
        return .init(
            module: "system",
            item: "account",
            keys: ["0xd857fcac7bd9bb03551d70b9743895a98b74b06e54bdc34f1b27ab240356857d".hex.decode() ?? Data()])
        { account in
            // Random Kusama validator account, as long as it participates in validation, all fields should be > 0
            account.data.feeFrozen.value > BigInt.zero &&
            account.data.reserved.value > BigInt.zero &&
            account.data.miscFrozen.value > BigInt.zero &&
            account.data.free.value > BigInt.zero
        }
    }
    
    func testService() {
        guard let client = client else {
            XCTFail()
            return
        }
        
        testStorageItemFetching(client: client, item: storageItem)
        testStorageItemFetching(client: client, item: storageItemAccount)
        
        testStorageItemFinding(client: client, item: storageItem)
        testStorageItemFinding(client: client, item: storageItemAccount)
    }
    
    private func testStorageItemFetching<T: Decodable>(client:  SubstrateClient, item: RpcStorageItem<T>) {
        let expectation = XCTestExpectation()
        
        let service = SubstrateStorageService(
            lookup: client.lookupService(),
            stateRpc: client.module.stateRpc()
        )
        
        service.fetch(
            moduleName: item.module,
            itemName: item.item,
            keys: item.keys
        ) { (response: T?, error: RpcError?) in
            XCTAssertNotNil(response)
            guard let result = response else {
                XCTFail()
                expectation.fulfill()
                return
            }
            
            XCTAssertEqual(item.validate(value: result), true)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: Constants.expectationLongTimeout)
    }
    
    private func testStorageItemFinding<T: Codable>(
        client:  SubstrateClient,
        item: RpcStorageItem<T>
    ) {
        let expectation = XCTestExpectation()
        let service = SubstrateStorageService(
            lookup: client.lookupService(),
            stateRpc: client.module.stateRpc()
        )
        
        service.find(moduleName: item.module, itemName: item.item)
            .first()
            .sink { [weak self] result in
                XCTAssertNotNil(result)
                do {
                    try self?.handleFoundItem(
                        result,
                        for: item,
                        using: service,
                        expectation: expectation
                    )
                } catch let error {
                    XCTFail(error.localizedDescription)
                }
            }
            .store(in: &anyCancellables)
        
        wait(for: [expectation], timeout: Constants.expectationLongTimeout)
    }
    
    private func handleFoundItem<T: Codable>(
        _ result: FindStorageItemResult?,
        for item: RpcStorageItem<T>,
        using service: SubstrateStorageService,
        expectation: XCTestExpectation
    ) throws {
        guard let storage = result?.storage, let resultItem = result?.item else {
            XCTFail()
            return
        }
        
        try service.fetch(
            item: resultItem,
            keys: item.keys,
            storage: storage
        ) { (response: T?, error: RpcError?)  in
            guard let result = response else {
                XCTFail()
                expectation.fulfill()
                return
            }
            
            XCTAssertEqual(item.validate(value: result), true)
            expectation.fulfill()
        }
    }
}
