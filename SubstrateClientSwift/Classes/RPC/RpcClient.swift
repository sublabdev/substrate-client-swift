/**
 *
 * Copyright 2023 SUBSTRATE LABORATORY LLC <info@sublab.dev>
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0

 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 * 
 */

import Foundation

/// Possible RPC errors
public enum RpcError: Error {
    case failedToPrepareRequest
    case bodyEncodingFailed(Error)
    case responseError(RpcResponseError)
}

/// RPC client that handles sending requests
public final class RpcClient {
    private enum Constants {
        static let scheme = "https"
    }
    
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
    
    /// Sends a ready `RpcRequest`.
    /// The request's and response's types should be explicitly specified.
    /// - Parameters:
    ///     - rpcRequest: `RpcRequest` that takes a generic codable params
    ///     - completion: Completion with either the request's optional result or `RpcError`
    public func send<Request: Encodable, Response: Decodable>(
        _ rpcRequest: RpcRequest<Request>,
        completion: @escaping (RpcResponse<Response>?, RpcError?) -> Void
    ) {
        var urlComponents = URLComponents()
        urlComponents.scheme = Constants.scheme
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
    
    /// Sends a generic request, conforming to `Encodable`.
    /// The request's and response's types should be explicitly specified.
    /// - Parameters:
    ///     - request: A generic request, conforming to `Encodable`
    /// - Returns: The expected `Decodable` generic response
    public func send<Request: Encodable, Response: Decodable>(
        _ rpcRequest: RpcRequest<Request>
    ) async throws -> RpcResponse<Response> {
        try await withCheckedThrowingContinuation { continuation in
            self.send(rpcRequest) { (response: RpcResponse<Response>?, error: RpcError?) in
                guard let response = response else {
                    if let error = error {
                        continuation.resume(throwing: error)
                    } else {
                        continuation.resume(throwing: RpcError.responseError(.noData))
                    }
                    return
                }
                
                continuation.resume(returning: response)
            }
        }
    }
    
    /// Sends a generic request, conforming to `Encodable`.
    /// The request's and response's types should be explicitly specified.
    /// - Parameters:
    ///     - rpcRequest: params for `RpcRequest`
    ///     - method: The method to be used in `RpcRequest`
    ///     - completion: Completion with the request's result
    public func sendRequest<Request: Encodable, Response: Decodable>(
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
    
    /// Sends a generic request, conforming to `Encodable`.
    /// The request's and response's types should be explicitly specified.
    /// - Parameters:
    ///     - request: A generic request, conforming to `Encodable`
    ///     - method: The method to be used in `RpcRequest`
    /// - Returns: The expected `Decodable` generic response
    public func sendRequest<Request: Encodable, Response: Decodable>(
        _ request: Request,
        method: String
    ) async throws -> Response? {
        try await withCheckedThrowingContinuation { continuation in
            self.sendRequest(request, method: method) { (response: Response?, error: RpcError?) in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: response)
                }
            }
        }
    }
    
    /// Sends a request by only setting the method.
    /// The response's type should be explicitly specified.
    /// - Parameters:
    ///     - method: The method to be used in `RpcRequest`
    ///     - completion: Completion with the request's optional result or an optional `RpcError`
    public func sendRequest<Response: Decodable>(
        method: String,
        completion: @escaping (Response?, RpcError?) -> Void
    ) {
        sendRequest(Nothing(), method: method, completion: completion)
    }
    
    
    /// Sends a request by only setting the method.
    /// The response's type should be explicitly specified.
    /// - Parameters:
    ///     - method: The method to be used in `RpcRequest`
    /// - Returns: An response of a specified type
    public func sendRequest<Response: Decodable>(
        method: String
    ) async throws -> Response? {
        try await withCheckedThrowingContinuation { continuation in
            self.sendRequest(method: method) { (response: Response?, error: RpcError?) in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: response)
                }
            }
        }
    }
}
