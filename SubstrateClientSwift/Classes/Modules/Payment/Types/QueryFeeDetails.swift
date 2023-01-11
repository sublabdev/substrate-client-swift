import Foundation
import CommonSwift
import BigInt

/// Contains details of query fee
public struct QueryFeeDetails {
    let baseFee: Balance
    let lenFee: Balance
    let adjustedWeightFee: Balance
}

class QueryFeeDetailsResponse: Codable {
    let inclusionFee: InclusionFee
    
    init(inclusionFee: InclusionFee) {
        self.inclusionFee = inclusionFee
    }
    
    struct InclusionFee: Codable {
        let baseFee: String
        let lenFee: String
        let adjustedWeightFee: String
    }
    
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
