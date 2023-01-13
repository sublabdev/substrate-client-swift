import Foundation

/// Possible RPC errors
public enum RpcError: Error {
    case failedToPrepareRequest
    case bodyEncodingFailed(Error)
    case responseError(RpcResponseError)
}

/// RPC client that handles sending requests
public class RpcClient {
    private let host: String
    private let path: String?
    private let params: [String: String?]
    
    public init(
        host: String,
        path: String? = nil,
        params: [String: String?] = [:],
        urlSession: URLSession = .shared
    ) {
        self.host = host
        self.path = path
        self.params = params
        self.urlSession = urlSession
    }
    
    private let urlSession: URLSession
    private var requestId: Int32 = 0
    
    /// Sends a ready `RpcRequest`
    /// - Parameters:
    ///     - rpcRequest: `RpcRequest` that takes a generic codable params
    ///     - completion: Completion with either the request's optional result or `RpcError`
    func send<Request: Codable, Response: Codable>(
        _ rpcRequest: RpcRequest<Request>,
        completion: @escaping (RpcResponse<Response>?, RpcError?) -> Void
    ) {
        var urlComponents = URLComponents()
        urlComponents.scheme = "https" // TODO: move to constants
        urlComponents.host = host
        urlComponents.path = "/\(path ?? "")"
        urlComponents.queryItems = params.map { .init(name: $0, value: $1) }
        guard let url = urlComponents.url else {
            completion(nil, .failedToPrepareRequest)
            return
        }
        
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        
        do {
            let encodedData = try JSONEncoder().encode(rpcRequest)
            request.httpBody = encodedData
        } catch let error {
            completion(nil, .bodyEncodingFailed(error))
            return
        }
        
        let task = urlSession.dataTask(with: request) { data, response, error in
            if let error = error, let response = response as? HTTPURLResponse {
                completion(nil, .responseError(.httpError(error.localizedDescription, response.statusCode)))
            }
            
            guard let data = data else {
                completion(nil, .responseError(.noData))
                return
            }
            
            do {
                let response = try JSONDecoder().decode(RpcResponse<Response>.self, from: data)
                if let error = response.error {
                    completion(nil, .responseError(.requestFailed(error.message)))
                } else {
                    completion(response, nil)
                }
            } catch let error {
                completion(nil, .responseError(.responseParsingFailure(data, error.localizedDescription)))
            }
        }
        
        task.resume()
    }
    
    /// Sending a request by creating `RpcRequest`
    /// - Parameters:
    ///     - rpcRequest: params for `RpcRequest`
    ///     - method: The method to be used in `RpcRequest`
    ///     - completion: Completion with the request's result
    func sendRequest<Request: Codable, Response: Codable>(
        _ request: Request,
        method: String,
        completion: @escaping (Response?, RpcError?) -> Void
    ) {
        let rpcRequest = RpcRequest<Request>(id: requestId, method: method, params: request)
        requestId += 1
        
        send(rpcRequest) { response, error in
            completion(response?.result, error)
        }
    }
    
    /// Sending a request by only setting the method
    /// - Parameters:
    ///     - method: The method to be used in `RpcRequest`
    ///     - completion: Completion with the request's result
    func sendRequest<Response: Codable>(
        method: String,
        completion: @escaping (Response?, RpcError?) -> Void
    ) {
        sendRequest(Nothing(), method: method, completion: completion)
    }
}
