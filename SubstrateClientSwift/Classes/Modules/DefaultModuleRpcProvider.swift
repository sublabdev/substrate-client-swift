import Foundation
import ScaleCodecSwift

class DefaultModuleRpcProvider: ModuleRpcProvider {
    let codec: ScaleCoder
    let rpcClient: RpcClient
    let hashersProvider: HashersProvider
    var client: SubstrateClient? = nil
    
    init(
        codec: ScaleCoder,
        rpcClient: RpcClient,
        hashersProvider: HashersProvider
    ) {
        self.codec = codec
        self.rpcClient = rpcClient
        self.hashersProvider = hashersProvider
    }
    
    func stateRpc() -> StateRpc {
        StateRpcClient(codec: codec, rpcClient: rpcClient, hashersProvider: hashersProvider)
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
