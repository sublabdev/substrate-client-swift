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
            let baseFeeValue = inclusionFee.baseFee.uInt128(),
            let lenFeeValue = inclusionFee.lenFee.uInt128(),
            let adjustedWeightFeeValue = inclusionFee.adjustedWeightFee.uInt128()
        else {
            return nil
        }
        
        return QueryFeeDetails(
            baseFee: baseFeeValue,
            lenFee: lenFeeValue,
            adjustedWeightFee: adjustedWeightFeeValue
        )
    }
}
