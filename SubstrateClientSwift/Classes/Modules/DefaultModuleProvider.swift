/**
 *
 * Copyright 2023 SUBSTRATE LABORATORY LLC <info@sublab.dev>
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0

 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 * 
 */

import Foundation
import ScaleCodecSwift

/// Default module provider
class DefaultModuleProvider: InternalModuleProvider {
    weak var constants: SubstrateConstants?
    weak var storage: SubstrateStorage?
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
    
    lazy var state: StateModule = StateModuleClient(codec: codec, rpcClient: rpcClient, hashersProvider: hashersProvider)
    lazy var system: SystemModule = SystemModuleClient(constants: constants, storage: storage)
    lazy var chain: ChainModule = ChainModuleClient(rpcClient: rpcClient)
    lazy var payment: PaymentModule = PaymentModuleClient(rpcClient: rpcClient)
}
