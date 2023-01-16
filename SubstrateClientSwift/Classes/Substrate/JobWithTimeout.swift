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

/// Performing job with given timeout
final class JobWithTimeout {
    let job: () async throws -> Void
    let timeout: TimeInterval
    private var lastUpdateDate: Date? = nil
    
    init(timeout: TimeInterval, job: @escaping () async throws -> Void) {
        self.job = job
        self.timeout = timeout
    }
    
    func performIfNeeded() {
        let now = Date()
        
        var updateNeeded = lastUpdateDate == nil
        
        if let lastUpdateDate = lastUpdateDate, now.timeIntervalSince(lastUpdateDate) > timeout {
            updateNeeded = true
        }
        
        if updateNeeded {
            Task { [weak self] in
                try await self?.job()
                self?.lastUpdateDate = now
            }
        }
    }
}
