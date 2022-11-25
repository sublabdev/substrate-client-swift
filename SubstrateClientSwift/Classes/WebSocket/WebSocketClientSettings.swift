import Foundation

struct WebSocketClientSettings {
    enum Policy {
        case none
        case firstSubscriber
        case allSubscribers
    }
    
    var policy: Policy = .none
}
