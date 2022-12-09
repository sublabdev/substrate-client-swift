import Foundation

/// Default hashers provider
struct DefaultHashersProvider: HashersProvider {
    func getStorageHasher(storage: RuntimeModuleStorage) -> StorageHashing {
        StorageHasher(storage: storage)
    }
}
