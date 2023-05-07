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

/// Runtime version
public struct RuntimeVersion: Codable {
    public let specName: String
    public let implName: String
    public let authoringVersion: Index
    public let specVersion: Index
    public let implVersion: Index
    public let apis: [RuntimeVersionApi]
    public let txVersion: Index
    public let stateVersion: UInt8
}

public struct RuntimeVersionApi: Codable {
    @Array8 public var id: [UInt8]
    public let index: Index
}
