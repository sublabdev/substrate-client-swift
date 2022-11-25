import Foundation

enum RpcError: Error {
    case requestBodyEncodingError(Error)
    case responseError(RpcResponseError)
}

class RpcClient {
    private var url: URL
    private let urlSession: URLSession
    private var requestId: Int64 = 0
    
    // TODO: Try String randomly generated instead of Int64
    
    init(url: URL, session: URLSession = .shared) {
        self.url = url
        urlSession = session
    }
    
    func send<Request: Codable, Response: Codable>(
        _ rpcRequest: RpcRequest<Request>,
        completion: @escaping (RpcResponse<Response>?, RpcError?) -> Void
    ) {
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        
        do {
            let encodedData = try JSONEncoder().encode(rpcRequest)
            request.httpBody = encodedData
        } catch let error {
            completion(nil, .requestBodyEncodingError(error))
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
                completion(response, nil)
            } catch let error {
                completion(nil, .responseError(.responseParsingFailure(data, error.localizedDescription)))
            }
        }
        
        task.resume()
    }
    
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
    
    func sendRequest<Response: Codable>(
        method: String,
        completion: @escaping (Response?, RpcError?) -> Void
    ) {
        sendRequest(Nothing(), method: method, completion: completion)
    }
}
