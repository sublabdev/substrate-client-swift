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
import SubstrateClientSwift

enum Network: CaseIterable {
    case kusama
    case polkadot
    case westend
    
    private var bundle: Bundle {
        Bundle(for: TestRuntimeMetadata.self)
    }
    
    var host: String {
        switch self {
        case .kusama: return "kusama.api.onfinality.io"
        case .polkadot: return "polkadot.api.onfinality.io"
        case .westend: return "westend.api.onfinality.io"
        }
    }
    
    var addressType: Int {
        switch self {
        case .kusama: return 2
        case .polkadot: return 1
        case .westend: return 42
        }
    }
    
    var genesisHash: String {
        switch self {
        case .kusama: return "0xb0a8d493285c2df73290dfb7e61f870f17b41801197a149ca93654499ea3dafe"
        case .polkadot: return "0x91b171bb158e2d3848fa23a9f1c25182fb8e20313b2c1eb49219da7a70ce90c3"
        case .westend: return "0xe143f23803ac50e8f6f8e62695d1ce9e4e1d68aa36c1cd2cfd15340213f3423e"
        }
    }
    
    var localRuntimeMetadataSnapshot: LocalRuntimeMetadataSnapshot {
        switch self {
        case .kusama:
            return .init(
                localURL: bundle.url(forResource: "kusama-metadata", withExtension: "")!,
                magicNumber: 1635018093
            )
            
        case .polkadot:
            return .init(
                localURL: bundle.url(forResource: "polkadot-metadata", withExtension: "")!,
                magicNumber: 1635018093
            )
           
        case .westend:
            return .init(
                localURL: bundle.url(forResource: "westend-metadata", withExtension: "")!,
                magicNumber: 1635018093
            )
        }
    }
    
    private func makeSettings() -> SubstrateClientSettings {
        let def = SubstrateClientSettings.default()
        
        return .init(
            rpcPath: "rpc",
            rpcParams: ["apikey": Constants.onFinalityKey],
            webSocketPath: "ws",
            webSocketParams: ["apikey": Constants.onFinalityKey],
            webSocketSecure: true,
            runtimeMetadataUpdateTimeoutMs: def.runtimeMetadataUpdateTimeoutMs,
            namingPolicy: def.namingPolicy
        )
    }
    
    func makeClient() -> SubstrateClient {
        .init(host: host, settings: makeSettings())
    }
    
    func makeRpcClient(urlSession: URLSession = .shared) -> Rpc {
        RpcClient(host: host, path: "rpc", params: ["apikey": Constants.onFinalityKey], urlSession: urlSession)
    }
}
