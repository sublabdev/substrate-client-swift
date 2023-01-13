import Foundation

/// Default hashers provider
struct DefaultHashersProvider: HashersProvider {
    /// Storage hashing interface for a specific runtime module storage
    /// - Parameters:
    ///     - storage: Runtime module storage for which storage hashing interface is returned
    /// - Returns: Storage hashing interface for a runtime module
    func getStorageHasher(storage: RuntimeModuleStorage) -> StorageHashing {
        StorageHasher(storage: storage)
    }
}
