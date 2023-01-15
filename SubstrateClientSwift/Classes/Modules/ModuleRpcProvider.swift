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
