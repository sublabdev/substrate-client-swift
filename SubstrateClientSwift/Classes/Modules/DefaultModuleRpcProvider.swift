import Foundation
import ScaleCodecSwift

struct DefaultModuleRpcProvider: ModuleRpcProvider {
    let codec: ScaleCoder
    let rpcClient: RpcClient
    let hashersProvider: HashersProvider
    
    func stateRpc() -> StateRpc {
        StateRpcClient(codec: codec, rpcClient: rpcClient, hashersProvider: hashersProvider)
    }
}
