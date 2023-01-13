import XCTest
import ScaleCodecSwift
import CommonSwift
@testable import SubstrateClientSwift

class TestRuntimeMetadata: XCTestCase {
    private let bundle = Bundle(for: TestRuntimeMetadata.self)
    
    func testLocalMetadataParsing() {
        Network.allCases.forEach {
            parseLocalMetadata(
                for: $0.localRuntimeMetadataSnapshot.localURL,
                magicNumber: $0.localRuntimeMetadataSnapshot.magicNumber
            )
        }
    }
    
    func testMetadataVersion() {
        Network.allCases.forEach {
            testMetadataVersion(using: $0.makeRpcClient())
        }
    }
    
    private func testMetadataVersion(using client: RpcClient) {
        client.sendRequest(method: "state_getMetadata") { [weak self] (response: String?, error: RpcError?) in
            if let error = error {
                XCTFail(error.localizedDescription)
                return
            }
            
            guard let string = response else {
                XCTFail()
                return
            }
            
            do {
                guard let runtimeMetadata = try self?.getMetadata(from: string) else {
                    XCTFail()
                    return
                }
                
                XCTAssertEqual(runtimeMetadata.version, 14)
                
            } catch let error {
                XCTFail(error.localizedDescription)
            }
        }
    }
    
    private func parseLocalMetadata(for url: URL?, magicNumber: UInt32) {
        guard let url = url else {
            XCTFail()
            return
        }
        
        do {
            let string = try String(contentsOf: url, encoding: .utf8)
            
            guard let runtimeMetadata = try getMetadata(from: string) else {
                XCTFail()
                return
            }
            
            XCTAssertEqual(runtimeMetadata.magicNumber, magicNumber)
        } catch let error {
            XCTFail("\(error)")
        }
    }
    
    private func getMetadata(from string: String) throws -> RuntimeMetadata? {
        guard let hexData = string.hex.decode() else {
            XCTFail()
            return nil
        }
        
        let codec = ScaleCoder.default()
        return try codec.decoder.decode(RuntimeMetadata.self, from: hexData)
    }
}
