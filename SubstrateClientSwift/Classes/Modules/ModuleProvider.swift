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

/// An interface for getting `State`; `System`; `Chain` and `Payment` modules
public protocol ModuleProvider: AnyObject {
    /// An interface for getting `RuntimeMetadata` and fetching `StorageItems`
    var state: StateModule { get }
    
    /// An interface for getting `RuntimeVersion`
    var system: SystemModule { get }
    
    /// An interface for `Chain` module
    var chain: ChainModule { get }
    
    /// An interface for `Payment` module
    var payment: PaymentModule { get }
}

/// An internal interface for working with cliend
protocol InternalModuleProvider: ModuleProvider {
    var constants: SubstrateConstants? { get set }
    var storage: SubstrateStorage? { get set }
}
