import Foundation
import BigInt

class ExtraExtrinsic: Hashable, Equatable {
    var era: Era
    let nonce: BigInt
    let tip: Balance
    
    init(era: Era = .immortal(value: Immortal()), nonce: BigInt, tip: Balance) {
        self.era = era
        self.nonce = nonce
        self.tip = tip
    }
    
    // TODO: Check hasher's logic here
    func hash(into hasher: inout Hasher) {
        hasher.combine(nonce)
    }
    
    // TODO: Check the Equatable's logic here
    static func ==(lhs: ExtraExtrinsic, rhs: ExtraExtrinsic) -> Bool {
        lhs.nonce == rhs.nonce && lhs.tip == rhs.tip && lhs.era == rhs.era
    }
}
