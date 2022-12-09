import XCTest
@testable import SubstrateClientSwift
import BigInt
import Combine

private struct RpcConstant<T: Equatable> {
    let module: String
    let constant: String
    let expectedValue: T
}

class TestFetchingConstants: XCTestCase {
    private var anyCancellables = Set<AnyCancellable>()
    private let network: Endpoint = .kusama
    private lazy var client: SubstrateClient? = {
        guard let url = URL(string: network.endpointInfo.url) else { return nil }
        return SubstrateClient(url: url)
    }()
    
    private let constants: [Any] = [
        RpcConstant<UInt64>(module: "babe", constant: "EpochDuration", expectedValue: 600),
        RpcConstant<UInt64>(module: "babe", constant: "ExpectedBlockTime", expectedValue: 6000),
        RpcConstant<UInt64>(module: "balances", constant: "ExistentialDeposit", expectedValue: 333333333), // With -1 digit it fails
        RpcConstant<UInt64>(module: "crowdloan", constant: "MinContribution", expectedValue: 999999999000), // With -1 digit (9) it fails
        RpcConstant<UInt32>(module: "staking", constant: "BondingDuration", expectedValue: 28),
        RpcConstant<UInt32>(module: "staking", constant: "MaxNominations", expectedValue: 24),
        RpcConstant<UInt32>(module: "staking", constant: "SessionsPerEra", expectedValue: 6),
        RpcConstant<UInt32>(module: "system", constant: "BlockHashCount", expectedValue: 4096),
        RpcConstant<UInt16>(module: "system", constant: "SS58Prefix", expectedValue: 2),
        RpcConstant<UInt64>(module: "timestamp", constant: "MinimumPeriod", expectedValue: 3000)
    ]
    
    func testService() {
        guard let client = client else {
            XCTFail()
            return
        }
        
        for constant in constants {
            if let rpcConstant = rpcConstant(from: constant, with: UInt16.self) {
                testStorageItem(client: client, constant: rpcConstant)
            } else if let rpcConstant = rpcConstant(from: constant, with: UInt32.self) {
                testStorageItem(client: client, constant: rpcConstant)
            } else if let rpcConstant = rpcConstant(from: constant, with: UInt64.self) {
                testStorageItem(client: client, constant: rpcConstant)
            } else {
                XCTFail()
            }
        }
    }
    
    private func testStorageItem<T: Codable>(client: SubstrateClient, constant: RpcConstant<T>) {
        testStorageItemFinding(client: client, constant: constant)
        testStorageItemFetching(client: client, constant: constant)
    }
    
    private func rpcConstant<T: Equatable>(from constant: Any, with expectedType: T.Type) -> RpcConstant<T>? {
        constant as? RpcConstant<T>
    }
    
    private func testStorageItemFetching<T: Codable>(client: SubstrateClient, constant: RpcConstant<T>) {
        let expectation = XCTestExpectation()
        let service = SubstrateConstantsService(codec: client.codec, lookup: client.lookupService())
        
        service.fetch(
            moduleName: constant.module,
            constantName: constant.constant
        ) { (response: T?, error: SubstrateConstantsService.ConstantServiceError?) in
            XCTAssertEqual(response, constant.expectedValue)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: Constants.expectationLongTimeout)
    }
    
    private func testStorageItemFinding<T: Codable>(client: SubstrateClient, constant: RpcConstant<T>) {
        let expectation = XCTestExpectation()
        let service = SubstrateConstantsService(codec: client.codec, lookup: client.lookupService())
        
        service.find(moduleName: constant.module, constantName: constant.constant)
            .first()
            .sink { [weak self] result in
                XCTAssertNotNil(result)
                self?.fetchExpectedValueForModuleConstant(
                    runtimeModuleConstant: result,
                    for: constant,
                    using: service,
                    expectation: expectation
                )
            }
            .store(in: &anyCancellables)
        
        wait(for: [expectation], timeout: Constants.expectationLongTimeout)
    }
    
    private func fetchExpectedValueForModuleConstant<T: Codable>(
        runtimeModuleConstant: RuntimeModuleConstant?,
        for constant: RpcConstant<T>,
        using service: SubstrateConstantsService,
        expectation: XCTestExpectation
    ) {
        guard let moduleConstant = runtimeModuleConstant else {
            XCTFail()
            return
        }
        
        do {
            let fetchedValue = try service.fetch(T.self, constant: moduleConstant)
            XCTAssertEqual(constant.expectedValue, fetchedValue)
            expectation.fulfill()
        } catch {
            XCTFail()
        }
    }
}
