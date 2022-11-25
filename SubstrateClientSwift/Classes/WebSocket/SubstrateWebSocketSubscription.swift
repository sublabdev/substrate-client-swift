import Foundation

final class SubstrateWebSocketSubscription: Hashable {
    let id: String
    var externalId: String? = nil
    let action: (String) -> Void
    
    init(id: String, externalId: String? = nil, action: @escaping (String) -> Void) {
        self.id = id
        self.externalId = externalId
        self.action = action
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: SubstrateWebSocketSubscription, rhs: SubstrateWebSocketSubscription) -> Bool {
        lhs.id == rhs.id
    }
}
