import Foundation

/// An interface for providing a storage hasher
protocol HashersProvider {
    /// Provides a storage hasher for a specified storage
    /// - Parameters:
    ///     - storage: The module storage which needs to be hashed
    /// - Returns: A storage hasher
    func getStorageHasher(storage: RuntimeModuleStorage) -> StorageHashing
}
