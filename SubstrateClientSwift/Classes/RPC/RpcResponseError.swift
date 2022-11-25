import Foundation

enum RpcResponseError: Codable {
    case httpError(String, Int)
    case noData
    case responseParsingFailure(Data, String)
}
