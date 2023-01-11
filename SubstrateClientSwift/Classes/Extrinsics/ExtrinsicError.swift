import Foundation

enum ExtrinsicError: Error {
    case runtimeCallUnknown
    case runtimeVersionNotKnown
    case genesisHashNotKnown
    case extrinsicBuildFailedDueToLookupFailure
}
