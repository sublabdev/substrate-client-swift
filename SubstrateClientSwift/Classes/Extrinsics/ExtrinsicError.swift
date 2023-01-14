import Foundation

/// Extrinsic possible errors
enum ExtrinsicError: Error {
    // used in service
    case runtimeVersionNotLoaded
    case genesisHashNotLoaded(RpcError?)
    
    // used in composition
    case noPayload
    case noRuntimeMetadata
    case noCodec
    case noNonce
    case noGenesisHash
    case noBlockHash
    case noRuntimeVersion
    case lookupFailure
}
