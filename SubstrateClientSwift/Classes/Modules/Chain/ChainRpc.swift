import Foundation
import ScaleCodecSwift

/// An interface for chain RPC client
protocol ChainRpc {
    /// Gets block hash using the provided number as a parameter for `RPC` request
    /// - Parameters:
    ///     - number: Number for which block hash should be fetched.
    ///     - completion: A completion closure with either an optional result or an optional `RpcError`
    func getBlockHash(number: Int, completion: @escaping (String?, RpcError?) -> Void) throws
}

/// Handles chain block hash fetching
public class ChainRpcClient: ChainRpc {
    private let rpcClient: RpcClient
    private let encoder: ScaleEncoder
    
    init(rpcClient: RpcClient, encoder: ScaleEncoder) {
        self.rpcClient = rpcClient
        self.encoder = encoder
    }
    
    func getBlockHash(number: Int, completion: @escaping (String?, RpcError?) -> Void) throws {
        let parameter = try encoder.encode(UInt(number))
        
        let request = RpcRequest(
            id: 0,
            method: "chain_getBlockHash",
            params: [parameter.hex.encode()]
        )
        
        rpcClient.send(request) { (response: RpcResponse<String>?, error: RpcError?) in
            guard error == nil else {
                completion(nil, error)
                return
            }
            
            completion(response?.result, nil)
        }
    }
}
