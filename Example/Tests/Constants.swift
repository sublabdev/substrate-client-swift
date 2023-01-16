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

enum Constants {
    static let testsCount = 1000
    static let webSocketPort = 8023
    static let webSocketUrl = "echo.ws.sublab.dev"
    static let onFinalityKey = "4d709852-8a96-4e7e-962d-0efe46d5a44c"
    
    static let expectationLongTimeout: TimeInterval = 60
    static let singleTestTime: TimeInterval = 3
}
