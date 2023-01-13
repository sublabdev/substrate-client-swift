import Foundation

/// Extrinsic possible errors
enum ExtrinsicError: Error {
    case runtimeCallUnknown
    case runtimeVersionNotKnown
    case genesisHashNotKnown
    case extrinsicBuildFailedDueToLookupFailure
}
