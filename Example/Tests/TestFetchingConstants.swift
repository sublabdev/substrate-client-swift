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
import ScaleCodecSwift
import CommonSwift

private struct RpcConstant<T: Equatable> {
    let module: String
    let constant: String
    let expectedValue: T
}

class TestFetchingConstants: XCTestCase {
    private let network: Network = .kusama
    private lazy var client = network.makeClient()
    
    private let constants: [Any] = [
        RpcConstant<UInt64>(module: "babe", constant: "EpochDuration", expectedValue: 600),
        RpcConstant<UInt64>(module: "babe", constant: "ExpectedBlockTime", expectedValue: 6000),
        RpcConstant<UInt64>(module: "balances", constant: "ExistentialDeposit", expectedValue: 333333333),
        RpcConstant<UInt64>(module: "crowdloan", constant: "MinContribution", expectedValue: 999999999000),
        RpcConstant<UInt32>(module: "staking", constant: "BondingDuration", expectedValue: 28),
        RpcConstant<UInt32>(module: "staking", constant: "MaxNominations", expectedValue: 24),
        RpcConstant<UInt32>(module: "staking", constant: "SessionsPerEra", expectedValue: 6),
        RpcConstant<UInt32>(module: "system", constant: "BlockHashCount", expectedValue: 4096),
        RpcConstant<UInt16>(module: "system", constant: "SS58Prefix", expectedValue: 2),
        RpcConstant<UInt64>(module: "timestamp", constant: "MinimumPeriod", expectedValue: 3000)
    ]
    
    func testService() async throws {
        for constant in constants {
            if let rpcConstant = rpcConstant(from: constant, with: UInt16.self) {
                try await testStorageItem(client: client, constant: rpcConstant)
            } else if let rpcConstant = rpcConstant(from: constant, with: UInt32.self) {
                try await testStorageItem(client: client, constant: rpcConstant)
            } else if let rpcConstant = rpcConstant(from: constant, with: UInt64.self) {
                try await testStorageItem(client: client, constant: rpcConstant)
            } else {
                XCTFail()
            }
        }
    }
    
    private func testStorageItem<T: Codable>(client: SubstrateClient, constant: RpcConstant<T>) async throws {
        try await testService(
            client: client,
            constant: constant
        )
    }
    
    // MARK: - Private
    private func testService<T: Codable>(
        client: SubstrateClient,
        constant: RpcConstant<T>
    ) async throws {
        try await testStorageItemFetching(
            constantService: client.constants,
            stateRpc: client.modules.state,
            constant: constant
        )
        
        try await testStorageItemFinding(
            constantService: client.constants,
            codec: client.codec,
            constant: constant
        )
    }
    
    private func rpcConstant<T: Equatable>(from constant: Any, with expectedType: T.Type) -> RpcConstant<T>? {
        constant as? RpcConstant<T>
    }
    
    private func testStorageItemFetching<T: Codable>(
        constantService: SubstrateConstantsService,
        stateRpc: StateModule,
        constant: RpcConstant<T>
    ) async throws {
        let storageItem: T? = try await constantService.fetch(moduleName: constant.module, constantName: constant.constant)
        XCTAssertEqual(storageItem, constant.expectedValue)
    }
    
    private func testStorageItemFinding<T: Codable>(
        constantService: SubstrateConstantsService,
        codec: ScaleCoder,
        constant: RpcConstant<T>
    ) async throws {
        let runtimeModuleConstant = try await constantService.find(moduleName: constant.module, constantName: constant.constant)
        try fetchExpectedValueForModuleConstant(
            runtimeModuleConstant: runtimeModuleConstant,
            for: constant,
            using: constantService
        )
    }
    
    private func fetchExpectedValueForModuleConstant<T: Codable>(
        runtimeModuleConstant: RuntimeModuleConstant?,
        for constant: RpcConstant<T>,
        using service: SubstrateConstantsService
    ) throws {
        guard let moduleConstant = runtimeModuleConstant else {
            XCTFail()
            return
        }
        
        let fetchedValue = try service.fetch(T.self, constant: moduleConstant)
        XCTAssertEqual(constant.expectedValue, fetchedValue)
    }
}
