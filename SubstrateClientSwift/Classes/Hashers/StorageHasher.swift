import Foundation
import HashingSwift

/// Interface for providing a hashing functionality
public protocol StorageHashing {
    /// Hashes provided storage item. The hashing can be either plain or key-map
    /// - Parameters:
    ///     - storageItem: A storage item to hash
    ///     - keys: Keys for hashing by key-mapping
    /// - Returns: A hashed `Data`
    func hash(storageItem: RuntimeModuleStorageItem, keys: [Data]) throws -> Data
}

/// Handles storage hashing
public struct StorageHasher: StorageHashing {
    private let storage: RuntimeModuleStorage
    
    public init(storage: RuntimeModuleStorage) {
        self.storage = storage
    }
    
    public func hash(storageItem: RuntimeModuleStorageItem, keys: [Data]) throws -> Data {
        switch storageItem.type {
        case .plain:
            return try hashPlainKey(storageItem: storageItem)
        case .map(let value):
            assert(keys.count == value.hasers.count, "Keys count should be equal to hashers count")
            return try hashMapKey(storageItem: storageItem, keys: keys, hashers: value.hasers)
        }
    }
    
    /// Hashes plain using runtim module's storage and the module's storage item
    /// - Parameters:
    ///     - storageItem: A storage item to hash
    /// - Returns: A hashed `Data`
    private func hashPlainKey(storageItem: RuntimeModuleStorageItem) throws -> Data {
        try storage.prefix.hashing.xx128() + storageItem.name.hashing.xx128()
    }
    
    /// Hashes the key based on provided hasher's type
    /// - Parameters:
    ///     - key: The key to hash
    ///     - hasher: Runtime module storage hasher type
    /// - Returns: A hashed `Data`
    private func hash(key: Data, hasher: RuntimeModuleStorageHasher) throws -> Data? {
        switch hasher {
        case .blake128:
            return try key.hashing.blake2b_128()
        case .blake256:
            return try key.hashing.blake2b_256()
        case .blake128Concat:
            let data = try key.hashing.blake2b_128()
            return data + key
        case .twox128:
            return try key.hashing.xx128()
        case .twox256:
            return try key.hashing.xx256()
        case .twox64Concat:
            return try key.hashing.xx64() + key
        case .identity:
            return key
        }
    }
    
    /// Hashes provided storage item based on keys and hashers
    /// - Parameters:
    ///     - storageItem: A storage item to hash
    ///     - keys: Keys for hashing by key-mapping
    ///     - hashers: Runtime module storage hasher types
    /// - Returns: A hashed `Data`
    private func hashMapKey(
        storageItem: RuntimeModuleStorageItem,
        keys: [Data],
        hashers: [RuntimeModuleStorageHasher]
    ) throws -> Data {
        try hashers.enumerated()
            .compactMap { try hash(key: keys[$0], hasher: $1) }
            .reduce(hashPlainKey(storageItem: storageItem)) { result, hash in
            result + hash
        }
    }
}
