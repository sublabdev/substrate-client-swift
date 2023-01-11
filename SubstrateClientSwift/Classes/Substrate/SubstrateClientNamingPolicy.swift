import Foundation

/// Naming police for substrate client
public enum SubstrateClientNamingPolicy {
    case none
    case caseInsensitive
    
    func equals(lhs: String, rhs: String) -> Bool {
        switch self {
        case .none:
            return lhs == rhs
        case .caseInsensitive:
            return lhs.lowercased() == rhs.lowercased()
        }
    }
}
