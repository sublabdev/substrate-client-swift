import Foundation

/// Byte size types
enum ByteSizeType {
    case int128
    case uInt128
    case int256
    case uInt256
    case int512
    case uInt512
}

/// The byte size based on the provided type
/// - Parameters:
///     - byteSizeType: The type of byte size
///     - Returns: The size for a given type.
func byteSize(byteSizeType: ByteSizeType) -> Int {
    switch byteSizeType {
    case .int128, .uInt128:
        return 128 / 8
    case .int256, .uInt256:
        return 256 / 8
    case .int512, .uInt512:
        return 512 / 8
    }
}
