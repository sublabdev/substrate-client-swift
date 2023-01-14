import Foundation
import ScaleCodecSwift

/// Default module rpc provider
class DefaultModuleRpcProvider: InternalModuleRpcProvider {
    weak var constants: SubstrateConstantsService?
    weak var storage: SubstrateStorageService?
    weak var codec: ScaleCoder?
    let rpcClient: RpcClient // Holder of rpc client
    let hashersProvider: HashersProvider
    
    init(
        codec: ScaleCoder,
        rpcClient: RpcClient,
        hashersProvider: HashersProvider
    ) {
        self.codec = codec
        self.rpcClient = rpcClient
        self.hashersProvider = hashersProvider
    }
    
    lazy var stateRpc: StateRpc = StateRpcClient(codec: codec, rpcClient: rpcClient, hashersProvider: hashersProvider)
    lazy var systemRpc: SystemRpc = SystemRpcClient(constants: constants, storage: storage)
    lazy var chainRpc: ChainRpc = ChainRpcClient(rpcClient: rpcClient)
    lazy var paymentRpc: PaymentRpc = PaymentRpcClient(rpcClient: rpcClient)
}
