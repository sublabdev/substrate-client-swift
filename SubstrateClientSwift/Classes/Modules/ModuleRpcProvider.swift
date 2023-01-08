import Foundation

/// An interface for getting RPCs
protocol ModuleRpcProvider {
    /// Provides an interface for getting `RuntimeMetadata` and fetching `StorageItems`
    /// - Returns: And interface which defines methods for getting `RuntimeMetadata` and `StorageItems`
    func stateRpc() -> StateRpc
    
    /// Provides an interface for getting `RuntimeVersion`
    /// - Parameters:
    ///     completion: A completion with system RPC
    func systemRpc(completion: @escaping (SystemRpc) -> Void)
}

/// An internal interface for working with cliend
protocol InternalModuleRpcProvider: ModuleRpcProvider {
    /// Handles substrate client
    func workingWithClient(client: SubstrateClient)
}
