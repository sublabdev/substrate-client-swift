import Foundation

/// An interface for getting RPCs
public protocol ModuleRpcProvider: AnyObject {
    /// An interface for getting `RuntimeMetadata` and fetching `StorageItems`
    var stateRpc: StateRpc { get }
    
    /// An interface for getting `RuntimeVersion`
    var systemRpc: SystemRpc { get }
    
    /// An interface for chain `RPC` client
    var chainRpc: ChainRpc { get }
    
    /// An interface for payment `RPC` client
    var paymentRpc: PaymentRpc { get }
}

/// An internal interface for working with cliend
protocol InternalModuleRpcProvider: ModuleRpcProvider {
    var constants: SubstrateConstantsService? { get set }
    var storage: SubstrateStorageService? { get set }
}
