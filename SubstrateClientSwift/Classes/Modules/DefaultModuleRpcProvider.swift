import Foundation
import ScaleCodecSwift

class DefaultModuleRpcProvider: ModuleRpcProvider {
    let codec: ScaleCoder
    let rpcClient: RpcClient
    let hashersProvider: HashersProvider
    let clientQueue: DispatchQueue
    let innerQueue: DispatchQueue
    var client: SubstrateClient? = nil
    
    init(
        codec: ScaleCoder,
        rpcClient: RpcClient,
        hashersProvider: HashersProvider,
        clientQueue: DispatchQueue,
        innerQueue: DispatchQueue
    ) {
        self.codec = codec
        self.rpcClient = rpcClient
        self.hashersProvider = hashersProvider
        self.clientQueue = clientQueue
        self.innerQueue = innerQueue
    }
    
    func stateRpc() -> StateRpc {
        StateRpcClient(
            codec: codec,
            rpcClient: rpcClient,
            hashersProvider: hashersProvider,
            clientQueue: clientQueue,
            innerQueue: innerQueue
        )
    }
    
    func systemRpc(completion: @escaping (SystemRpc) -> Void) {
        client?.constantsService { [weak self] constantsService in
            self?.client?.storageService { storageService in
                completion(SystemRpcClient(constantsService: constantsService, storageService: storageService))
            }
        }
    }
    
    func chainRpc(completion: @escaping (ChainRpc) -> Void) {
        completion(ChainRpcClient(rpcClient: rpcClient, encoder: codec.encoder))
    }
}

extension DefaultModuleRpcProvider: InternalModuleRpcProvider {
    // Supply dependencies
    func workingWithClient(client: SubstrateClient) {
        self.client = client
    }
}
