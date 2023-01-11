import Foundation
import CommonSwift

/// Account information
public struct Account: Codable {
    public let nonce: Index
    public let consumers: Index
    public let providers: Index
    public let sufficients: Index
    public let data: AccountData
    
    public struct AccountData: Codable {
        public let free: Balance
        public let reserved: Balance
        public let miscFrozen: Balance
        public let feeFrozen: Balance
    }
}
