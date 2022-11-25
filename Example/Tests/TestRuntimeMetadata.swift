import XCTest
import ScaleCodecSwift
@testable import SubstrateClientSwift

class TestRuntimeMetadata: XCTestCase {
    private let bundle = Bundle(for: TestRuntimeMetadata.self)
    let adapterProvider = DefaultScaleCodecAdapterProvider()
    
    func testLocalMetadataParsing() {
        Endpoint.allCases.forEach {
            parseLocalMetadata(for: $0.endpointInfo.localURL, magicNumber: $0.endpointInfo.magicNumber)
        }
    }
    
    func testMetadataVersion() {
        Endpoint.allCases.forEach {
            testMetadataVersion(for: URL(string: $0.endpointInfo.url))
        }
    }
    
    private func testMetadataVersion(for url: URL?) {
        guard let url = url else {
            XCTFail()
            return
        }
        
        let client = RpcClient(url: url)
        
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
        guard let hexData = string.data(using: .hexadecimal) else {
            XCTFail()
            return nil
        }
        
        let codec = ScaleCoder(
            encoder: ScaleEncoder(adapterProvider: adapterProvider),
            decoder: ScaleDecoder(adapterProvider: adapterProvider)
        )
        
        return try codec.decoder.decode(RuntimeMetadata.self, from: hexData)
    }
}
