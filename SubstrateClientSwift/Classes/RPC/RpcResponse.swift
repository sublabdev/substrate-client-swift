import Foundation

/// RPC response
struct RpcResponse<T: Codable>: Codable {
    let jsonrpc: String
    let id: Int32
    var result: T? = nil
    var error: Error? = nil
    // TODO: similar names (RpcResponseError, Error), pls refactor, this one is definitely response error
    struct Error: Codable {
        let code: Int
        let message: String
    }
}
