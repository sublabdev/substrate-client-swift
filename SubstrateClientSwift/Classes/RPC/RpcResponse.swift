import Foundation

struct RpcResponse<T: Codable>: Codable {
    let jsonrpc: String
    let id: Int64
    var result: T? = nil
    var error: RpcResponseError? = nil
}
