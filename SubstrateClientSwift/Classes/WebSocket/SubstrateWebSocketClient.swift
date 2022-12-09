import Foundation

/// Substrate web socket client
public final class SubstrateWebSocketClient {
    private let client: WebSocketClientProtocol

    /// Creates a substrate web socket client
    init(wsClientBuilder: WebSocketClientBuilder) {
        client = wsClientBuilder.webSocketClient()
    }
    
    /// Sends a generic request
    /// - Parameters:
    ///     - request: Generic request conforming to `Codable`
    ///     - completion: Completion containing an optional `Error`
    func sendRequest<T: Codable>(_ request: T, completion: @escaping (Error?) -> Void) throws {
        let webSocketRequest = Request(id: UUID().uuidString, request: request)
        try sendRequest(webSocketRequest, completion: completion)
    }
    
    /// Subscribes to client's messages
    /// - Parameters:
    ///     - completion: Completion with either `URLSessionWebSocketTask.Message` or nil
    func subscribe(completion: @escaping (URLSessionWebSocketTask.Message?) -> Void) {
        client.subscribe(subscription: completion)
    }
    
    /// Subscribes to client's errors
    /// - Parameters:
    ///     - errorSubscription: Completion with `Error.Message`
    func subscribeToErrors(_ errorSubscription: @escaping (Error) -> Void) {
        client.subscribeToErrors(errorSubscription)
    }
    
    /// Sends an encoded request as a message of type `.data`
    /// - Parameters:
    ///     - request: Generic request conforming to `Codable`
    ///     - completion: Completion containing an optional `Error`
    private func sendRequest<T: Codable>(
        _ request: Request<T>,
        completion: @escaping (Error?) -> Void
    ) throws {
        let encodedRequest = try JSONEncoder().encode(request)
        client.sendMessage(.data(encodedRequest), completion: completion)
    }
}
