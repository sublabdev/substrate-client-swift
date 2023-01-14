import Foundation

/// RPC request with generic params
public struct RpcRequest<T: Encodable>: Encodable {
    public var jsonrpc = "2.0"
    public var id: Int32
    public var method: String
    public var params: T
}
