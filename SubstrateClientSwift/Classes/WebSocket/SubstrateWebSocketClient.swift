import Foundation

public final class SubstrateWebSocketClient {
    private let client: WebSocketClientProtocol

    init(wsClientBuilder: WebSocketClientBuilder) {
        client = wsClientBuilder.webSocketClient()
    }
    
    func sendRequest<T: Codable>(_ request: T, completion: @escaping (Swift.Error?) -> Void) throws {
        let webSocketRequest = Request(id: UUID().uuidString, request: request)
        try sendRequest(webSocketRequest, completion: completion)
    }
    
    func subscribe(_ subscription: @escaping (URLSessionWebSocketTask.Message) -> Void) {
        client.subscribe(subscription)
    }
    
    func subscribeToErrors(_ errorSubscription: @escaping (Swift.Error) -> Void) {
        client.subscribeToErrors(errorSubscription)
    }
    
    private func sendRequest<T: Codable>(_ request: Request<T>, completion: @escaping (Swift.Error?) -> Void) throws {
        let encodedRequest = try JSONEncoder().encode(request)
        client.sendMessage(.data(encodedRequest), completion: completion)
    }
}
