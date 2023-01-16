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
import CommonSwift
import BigInt

/// Contains details of query fee
public struct QueryFeeDetails: Decodable {
    public let baseFee: Balance
    public let lenFee: Balance
    public let adjustedWeightFee: Balance
}

final class QueryFeeDetailsResponse: Codable {
    let inclusionFee: InclusionFee
    
    init(inclusionFee: InclusionFee) {
        self.inclusionFee = inclusionFee
    }
    
    struct InclusionFee: Codable {
        let baseFee: String
        let lenFee: String
        let adjustedWeightFee: String
    }
    
    /// Creates a query fee details from inclusion fee
    /// - Returns: Generated query fee details
    func toFinal() -> QueryFeeDetails? {
        guard
            let baseFeeValue = inclusionFee.baseFee.hex.toBigUInt(),
            let lenFeeValue = inclusionFee.lenFee.hex.toBigUInt(),
            let adjustedWeightFeeValue = inclusionFee.adjustedWeightFee.hex.toBigUInt()
        else {
            return nil
        }
        
        return QueryFeeDetails(
            baseFee: .init(value: baseFeeValue),
            lenFee: .init(value: lenFeeValue),
            adjustedWeightFee: .init(value: adjustedWeightFeeValue)
        )
    }
}
