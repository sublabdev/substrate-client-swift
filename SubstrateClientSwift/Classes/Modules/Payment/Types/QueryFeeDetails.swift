import Foundation
import CommonSwift
import BigInt

/// Contains details of query fee
public struct QueryFeeDetails: Decodable {
    public let baseFee: Balance
    public let lenFee: Balance
    public let adjustedWeightFee: Balance
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
