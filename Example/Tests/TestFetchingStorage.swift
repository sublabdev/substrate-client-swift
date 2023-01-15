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

import XCTest
@testable import SubstrateClientSwift
import BigInt

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
    
    func validate(value: T) -> Bool {
        validation?(value) ?? true
    }
}

class TestFetchingStorage: XCTestCase {
    private let network: Network = .kusama
    private lazy var client = network.makeClient()
    
    private let storageItemFetchingExpectation = XCTestExpectation()
    private let storageItemAccountFetchingExpectation = XCTestExpectation()
    private let storageItemFindingExpectation = XCTestExpectation()
    private let storageItemAccountFindingExpectation = XCTestExpectation()
        
    private var storageItem: RpcStorageItem<UInt64> {
        .init(module: "timestamp", item: "now") {
            // Difference should be within one minute, let's assume some big lag
            let date1 = Date().timeIntervalSinceReferenceDate
            let date2 = Date(timeIntervalSinceNow: TimeInterval($0)).timeIntervalSinceReferenceDate
            return (date1 - date2) < Constants.expectationLongTimeout
        }
    }
    
    private func storageItemAccount() throws -> RpcStorageItem<Account> {
        let key = try "0xd857fcac7bd9bb03551d70b9743895a98b74b06e54bdc34f1b27ab240356857d".hex.decode()
        return .init(
            module: "system",
            item: "account",
            keys: [key]
        )
        { account in
            // Random Kusama validator account, as long as it participates in validation, all fields should be > 0
            account.data.feeFrozen.value > BigInt.zero &&
            account.data.reserved.value > BigInt.zero &&
            account.data.miscFrozen.value > BigInt.zero &&
            account.data.free.value > BigInt.zero
        }
    }
    
    func testStorageItem() async throws {
        try await testStorageItemFetching(
            storageService: client.storage,
            item: storageItem
        )

        try await testStorageItemFetching(
            storageService: client.storage,
            item: try storageItemAccount()
        )
        
        try await testStorageItemFinding(
            storageService: client.storage,
            item: storageItem
        )

        try await testStorageItemFinding(
            storageService: client.storage,
            item: storageItem
        )
    }
    
    private func testStorageItemFetching<T: Decodable>(
        storageService: SubstrateStorage,
        item: RpcStorageItem<T>
    ) async throws {
        let response: T? = try await storageService.fetch(
            moduleName: item.module,
            itemName: item.item,
            keys: item.keys
        )
        
        XCTAssertNotNil(response)
        
        guard let result = response else {
            XCTFail()
            return
        }
        
        let isValid = item.validate(value: result)
        
        if !isValid {
            print("not valid result: \(result)")
        }
        
        XCTAssertTrue(isValid)
    }
    
    private func testStorageItemFinding<T: Codable>(
        storageService: SubstrateStorage,
        item: RpcStorageItem<T>
    ) async throws {
        let result = try await storageService.find(moduleName: item.module, itemName: item.item)
        try await handleFoundItem(result, for: item, using: storageService)
    }
    
    private func handleFoundItem<T: Codable>(
        _ result: FindStorageItemResult?,
        for item: RpcStorageItem<T>,
        using service: SubstrateStorage
    ) async throws {
        guard let storage = result?.storage, let resultItem = result?.item else {
            XCTFail()
            return
        }
        
        let response: T? = try await service.fetch(
            item: resultItem,
            keys: item.keys,
            storage: storage
        )
        
        guard let result = response else {
            XCTFail()
            return
        }
        
        let isValid = item.validate(value: result)
        
        if !isValid {
            print("not valid result: \(result)")
        }
        
        XCTAssertTrue(isValid)
    }
}
