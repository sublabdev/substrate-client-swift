import XCTest
import ScaleCodecSwift
import CommonSwift
@testable import SubstrateClientSwift

class TestRuntimeMetadata: XCTestCase {
    private let bundle = Bundle(for: TestRuntimeMetadata.self)
    
    func testLocalMetadataParsing() throws {
        for network in Network.allCases {
            try parseLocalMetadata(
                for: network.localRuntimeMetadataSnapshot.localURL,
                magicNumber: network.localRuntimeMetadataSnapshot.magicNumber
            )
        }
    }
    
    func testMetadataVersion() async throws {
        for network in Network.allCases {
            try await testMetadataVersion(using: network.makeRpcClient())
        }
    }
    
    private func testMetadataVersion(using client: RpcClient) async throws {
        let response: String? = try await client.sendRequest(method: "state_getMetadata")
        guard let string = response else {
            XCTFail()
            return
        }
        
        guard let runtimeMetadata = try metadata(from: string) else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(runtimeMetadata.version, 14)
    }
    
    private func parseLocalMetadata(for url: URL?, magicNumber: UInt32) throws {
        guard let url = url else {
            XCTFail()
            return
        }
        
        let string = try String(contentsOf: url, encoding: .utf8)
        
        guard let runtimeMetadata = try metadata(from: string) else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(runtimeMetadata.magicNumber, magicNumber)
    }
    
    private func metadata(from string: String) throws -> RuntimeMetadata? {
        let encoded = try string.hex.decode()
        return try ScaleCoder.default().decoder.decode(RuntimeMetadata.self, from: encoded)
    }
}
