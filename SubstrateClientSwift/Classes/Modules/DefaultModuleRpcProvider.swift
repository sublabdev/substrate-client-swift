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
        client?.constantsService {
            completion(SystemRpcClient(constantsService: $0))
        }
    }
}

extension DefaultModuleRpcProvider: InternalModuleRpcProvider {
    // Supply dependencies
    func workingWithClient(client: SubstrateClient) {
        self.client = client
    }
}
