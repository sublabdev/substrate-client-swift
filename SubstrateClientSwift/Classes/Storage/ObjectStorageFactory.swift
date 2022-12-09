import Foundation
import Combine

/// An interface for making an in memory object storage which is a `PassthroughSubject` with optional generic type `T`
protocol ObjectStorageFactory {
    /// Makes an in memory object storage which is a `PassthroughSubject` with optional generic type `T`
    func make<T>() -> PassthroughSubject<T?, Never>
}
