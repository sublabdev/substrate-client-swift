import Foundation
import ScaleCodecSwift

/// An interface for getting a query fee details response
protocol PaymentRpc {
    /// Gets query fee details for a payload
    /// - Parameters:
    ///     - payload: `Payload` for which query fee details should be returned
    ///     - completion: A completion handler with either an optional `QueryFeeDetails` or an optional `RpcError`
    func queryFeeDetails(payload: Payload) async throws -> QueryFeeDetails?
}

/// Handles payment query fee details fetching
public class PaymentRpcClient: PaymentRpc {
    private weak var rpcClient: RpcClient?
    
    init(rpcClient: RpcClient?) {
        self.rpcClient = rpcClient
    }
    
    func queryFeeDetails(payload: Payload) async throws -> QueryFeeDetails? {
        guard let payloadData = try payload.toData() else { return nil }
        return try await rpcClient?.sendRequest(
            [payloadData.hex.encode(includePrefix: true)],
            method: "payment_queryFeeDetails"
        )
    }
}
