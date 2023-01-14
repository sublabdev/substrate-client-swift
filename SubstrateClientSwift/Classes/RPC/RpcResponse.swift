import Foundation

/// RPC response
public struct RpcResponse<T: Decodable>: Decodable {
    public let jsonrpc: String
    public let id: Int32
    public var result: T? = nil
    public var error: Error? = nil
   
    public struct Error: Decodable {
        public let code: Int
        public let message: String
    }
}
