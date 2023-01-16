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

/// Extrinsic possible errors
enum ExtrinsicError: Error {
    // used in service
    case runtimeVersionNotLoaded
    case genesisHashNotLoaded(RpcError?)
    
    // used in composition
    case noPayload
    case noRuntimeMetadata
    case noCodec
    case noNonce
    case noGenesisHash
    case noBlockHash
    case noRuntimeVersion
    case lookupFailure
}
