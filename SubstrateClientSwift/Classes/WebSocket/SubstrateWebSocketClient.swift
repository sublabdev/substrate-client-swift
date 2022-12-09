import Foundation
import Combine

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
    ///     - completion: Completion with `PassthroughSubject` that contains `URLSessionWebSocketTask`'s messages
    func subscribe(completion: @escaping (PassthroughSubject<URLSessionWebSocketTask.Message, Never>?) -> Void) {
        client.subscribe(completion: completion)
    }
    
    /// Subscribes to client's errors
    /// - Returns: `AnyPublisher` with `Error`
    func subscribeToErrors() -> AnyPublisher<Error, Never> {
        client.subscribeToErrors()
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
