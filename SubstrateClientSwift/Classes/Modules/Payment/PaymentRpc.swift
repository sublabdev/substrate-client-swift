import Foundation
import ScaleCodecSwift

/// An interface for getting a query fee details response
protocol PaymentRpc {
    /// Gets query fee details for a payload
    /// - Parameters:
    ///     - payload: `Payload` for which query fee details should be returned
    ///     - completion: A completion handler with either an optional `QueryFeeDetails` or an optional `RpcError`
    func getQueryFeeDetails(payload: Payload, completion: @escaping (QueryFeeDetails?, RpcError?) -> Void) throws
}

/// Handles payment query fee details fetching
public class PaymentRpcClient: PaymentRpc {
    private let scaleEncoder: ScaleEncoder
    private let rpcClient: RpcClient
    
    init(scaleEncoder: ScaleEncoder, rpcClient: RpcClient) {
        self.scaleEncoder = scaleEncoder
        self.rpcClient = rpcClient
    }
    
    func getQueryFeeDetails(payload: Payload, completion: @escaping (QueryFeeDetails?, RpcError?) -> Void) throws {
        // TODO: Check the encoding logic here
        let parameter = try scaleEncoder.encode(payload)
        
        let request = RpcRequest(
            id: 0,
            method: "payment_queryFeeDetails",
            params: [parameter.hex.encode(includePrefix: true)]
        )
        
        rpcClient.send(request) { (response: RpcResponse<QueryFeeDetailsResponse>?, error: RpcError?) in
            guard error == nil else {
                completion(nil, error)
                return
            }
            
            completion(response?.result?.toFinal(), nil)
        }
    }
}
