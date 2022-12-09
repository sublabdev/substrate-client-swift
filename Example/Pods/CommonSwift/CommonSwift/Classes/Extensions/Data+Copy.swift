import Foundation

extension Data {
    /// Copy of Data to the (but not including) the specified size
    /// - Parameters:
    ///     - size: The max value of a range (but not included) that should be copied
    func copyOf(size: Int) -> Data {
        self[0..<size]
    }
}
