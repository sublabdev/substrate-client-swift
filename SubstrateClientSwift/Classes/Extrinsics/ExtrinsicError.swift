import Foundation

/// Extrinsic possible errors
enum ExtrinsicError: Error {
    // used in service
    case runtimeVersionNotLoaded
    case genesisHashNotLoaded(RpcError?)
    
    // used in composition
    case noRuntimeMetadata
    case genesisHashEncodingFailed
    case blockHashEncodingFailed
    case lookupFailure
    case signingFailure
}
