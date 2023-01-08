import Foundation

extension UnsafeMutableRawBufferPointer {
    // Returns a typed pointer to a memory bound to UInt8
    var bufferPointer: UnsafeMutablePointer<UInt8> {
        baseAddress!.assumingMemoryBound(to: UInt8.self)
    }
}
