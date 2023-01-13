import Foundation

/// Web socket client settings which contains the policy for web socket. There are three types of policies:
///
/// `.none`: No subscriber recieves data
///
/// `.firstSubscriber`: Only the first subscriber recieves data
///
/// `.allSubscribers`: All subscribers recieve data
enum WebSocketClientSubscriptionPolicy {
    case none
    case firstSubscriber
    case allSubscribers
}
