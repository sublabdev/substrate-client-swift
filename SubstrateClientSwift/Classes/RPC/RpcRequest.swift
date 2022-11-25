import Foundation

struct RpcRequest<T: Codable>: Codable {
    var jsonrpc = "2.0"
    let id: Int64
    let method: String
    var params: T
}
