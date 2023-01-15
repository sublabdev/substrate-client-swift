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

/// Runtime type
public class RuntimeType: Codable {
    public let path: [String]
    public let params: [RuntimeTypeParam]
    public let def: RuntimeTypeDef
    public let docs: [String]
    
    public init(path: [String], params: [RuntimeTypeParam], def: RuntimeTypeDef, docs: [String]) {
        self.path = path
        self.params = params
        self.def = def
        self.docs = docs
    }
}
