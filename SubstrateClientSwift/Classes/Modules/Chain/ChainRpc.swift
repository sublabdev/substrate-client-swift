import Foundation
import ScaleCodecSwift

/// An interface for chain RPC client
public protocol ChainRpc: AnyObject {
    /// Gets block hash using the provided number as a parameter for `RPC` request
    /// - Parameters:
    ///     - number: Number for which block hash should be fetched.
    /// - Returns: Block hash for the provided number
    func blockHash(number: UInt) async throws -> String?
}

/// Handles chain block hash fetching
final class ChainRpcClient: ChainRpc {
    private weak var rpcClient: RpcClient?
    
    init(rpcClient: RpcClient?) {
        self.rpcClient = rpcClient
    }
    
    func blockHash(number: UInt) async throws -> String? {
        try await rpcClient?.sendRequest(
            [NumericAdapter.toData(number).hex.encode(includePrefix: true)],
            method: "chain_getBlockHash"
        )
    }
}
