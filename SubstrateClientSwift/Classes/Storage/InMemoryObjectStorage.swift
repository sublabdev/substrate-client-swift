import Foundation
import Combine

/// Creates in memory object storage which is a `PassthroughSubject` subject that either returns an optional
/// Generic type `T` or no error
struct InMemoryObjectStorageFactory: ObjectStorageFactory {
    func make<T>() -> PassthroughSubject<T?, Never> {
        PassthroughSubject()
    }
}
