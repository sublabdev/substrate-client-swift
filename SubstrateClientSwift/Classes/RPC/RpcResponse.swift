import Foundation

/// RPC response
struct RpcResponse<T: Codable>: Codable {
    let jsonrpc: String
    let id: Int32
    var result: T? = nil
    var error: RpcResponseError? = nil
   
    struct RpcResponseError: Codable {
        let code: Int
        let message: String
    }
}
