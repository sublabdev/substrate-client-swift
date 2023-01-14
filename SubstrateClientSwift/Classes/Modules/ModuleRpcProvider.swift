import Foundation

/// An interface for getting RPCs
public protocol ModuleRpcProvider: AnyObject {
    /// Provides an interface for getting `RuntimeMetadata` and fetching `StorageItems`
    /// - Returns: And interface which defines methods for getting `RuntimeMetadata` and `StorageItems`
    var stateRpc: StateRpc { get }
    
    /// Provides an interface for getting `RuntimeVersion`
    var systemRpc: SystemRpc { get }
    
    /// Provides an interface for chain `RPC` client
    var chainRpc: ChainRpc { get }
}

/// An internal interface for working with cliend
protocol InternalModuleRpcProvider: ModuleRpcProvider {
    var constants: SubstrateConstantsService? { get set }
    var storage: SubstrateStorageService? { get set }
}
