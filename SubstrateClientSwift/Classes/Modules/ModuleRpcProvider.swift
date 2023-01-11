import Foundation

/// An interface for getting RPCs
public protocol ModuleRpcProvider {
    /// Provides an interface for getting `RuntimeMetadata` and fetching `StorageItems`
    /// - Returns: And interface which defines methods for getting `RuntimeMetadata` and `StorageItems`
    func stateRpc() -> StateRpc
    
    /// Provides an interface for getting `RuntimeVersion`
    /// - Parameters:
    ///     completion: A completion with system RPC
    func systemRpc(completion: @escaping (SystemRpc) -> Void)
    
    /// Provides an interface for chain `RPC` client
    /// - Parameters:
    ///     completion: A completion with system chain `RPC`
    func chainRpc(completion: @escaping (ChainRpc) -> Void)
}

/// An internal interface for working with cliend
protocol InternalModuleRpcProvider: ModuleRpcProvider {
    /// Handles substrate client
    func workingWithClient(client: SubstrateClient)
}
