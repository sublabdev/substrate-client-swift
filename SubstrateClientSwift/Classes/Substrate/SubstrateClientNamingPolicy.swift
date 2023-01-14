import Foundation

/// Naming police for substrate client
public enum SubstrateClientNamingPolicy {
    case none
    case caseInsensitive
    
    func equals(_ lhs: String, _ rhs: String) -> Bool {
        switch self {
        case .none:
            return lhs == rhs
        case .caseInsensitive:
            return lhs.lowercased() == rhs.lowercased()
        }
    }
}
