import Foundation

extension UnsafeRawBufferPointer {
    // Returns a typed pointer to a memory bound to UInt8
    var bufferPointer: UnsafePointer<UInt8> {
        baseAddress!.assumingMemoryBound(to: UInt8.self)
    }
}
