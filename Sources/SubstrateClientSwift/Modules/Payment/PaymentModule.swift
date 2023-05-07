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

// MARK: - Protocol

/// An interface for getting a query fee details response
public protocol PaymentModule {
    /// Gets query fee details for a payload
    /// - Parameters:
    ///     - payload: `Payload` for which query fee details should be returned
    /// - Returns: An optional query fee details
    func queryFeeDetails(payload: Payload) async throws -> QueryFeeDetails?
}

// MARK: - Implementation

/// Handles payment query fee details fetching
final class PaymentModuleClient: PaymentModule {
    private weak var rpcClient: Rpc?
    
    init(rpcClient: Rpc?) {
        self.rpcClient = rpcClient
    }
    
    func queryFeeDetails(payload: Payload) async throws -> QueryFeeDetails? {
        let response: QueryFeeDetailsResponse? = try await rpcClient?.sendRequest(
            [try payload.toData().hex.encode(includePrefix: true)],
            method: "payment_queryFeeDetails"
        )
        
        return response.flatMap { $0.toFinal() }
    }
}
