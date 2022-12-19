import Foundation

protocol ModuleRpcProvider {
    /// Provides an interface for getting `RuntimeMetadata` and fetching `StorageItems`
    /// - Returns: And interface which defines methods for getting `RuntimeMetadata` and `StorageItems`
    func stateRpc() -> StateRpc
}
