import Foundation
import CommonSwift

typealias Balance = UInt128

/// Account information
struct Account: Codable {
    let nonce: UInt32
    let consumers: UInt32
    let providers: UInt32
    let sufficients: UInt32
    let data: AccountData
    
    struct AccountData: Codable {
        let free: Balance
        let reserved: Balance
        let miscFrozen: Balance
        let feeFrozen: Balance
    }
}
