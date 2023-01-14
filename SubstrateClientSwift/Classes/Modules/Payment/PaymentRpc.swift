import Foundation
import ScaleCodecSwift

/// An interface for getting a query fee details response
public protocol PaymentRpc {
    /// Gets query fee details for a payload
    /// - Parameters:
    ///     - payload: `Payload` for which query fee details should be returned
    ///     - completion: A completion handler with either an optional `QueryFeeDetails` or an optional `RpcError`
    func queryFeeDetails(payload: Payload) async throws -> QueryFeeDetails?
}

/// Handles payment query fee details fetching
final class PaymentRpcClient: PaymentRpc {
    private weak var rpcClient: RpcClient?
    
    init(rpcClient: RpcClient?) {
        self.rpcClient = rpcClient
    }
    
    func queryFeeDetails(payload: Payload) async throws -> QueryFeeDetails? {
        let response: QueryFeeDetailsResponse? = try await rpcClient?.sendRequest(
            [try payload.toData().hex.encode(includePrefix: true)],
            method: "payment_queryFeeDetails"
        )
        
        return response.flatMap { $0.toFinal() }
    }
}
