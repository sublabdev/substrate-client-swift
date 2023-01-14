import Foundation
import ScaleCodecSwift

/// Substrate storage service
public class SubstrateStorageService {
    private weak var lookup: SubstrateLookup?
    private weak var stateRpc: StateRpc?
    
    /// Creates a substrate storage service
    /// - Parameters:
    ///     - lookup: Substrate lookup serivce
    ///     - stateRpc: An interface for getting Runtime metadata and fetching Storage Items
    ///     - clientQueue: A client-specified queue on which fetched data will be returned. The default one is `main`
    ///     - innerQueue: An inner queue on which the logic takes place
    init(
        lookup: SubstrateLookup?,
        stateRpc: StateRpc?
    ) {
        self.lookup = lookup
        self.stateRpc = stateRpc
    }
    
    /// Finds a storage item result, which is a wrapper over runtime module storage item and runtime module storage itself,
    /// by previously fetching the module
    /// - Parameters:
    ///     - moduleName: Module's name to fetch
    ///     - itemName: Storage item's name
    /// - Returns: A storage item result from a module
    public func find(moduleName: String, itemName: String) async throws -> FindStorageItemResult? {
        try await lookup?.findStorageItem(moduleName: moduleName, itemName: itemName)
    }
    
    /// Fetches a storage item after getting a module first
    /// - Parameters:
    ///     - moduleName: Module's name to fetch
    ///     - itemName: Storage item's name
    ///     - completion: Completion with either a generic `T` or `RpcError`
    public func fetch<T: Decodable>(
        moduleName: String,
        itemName: String
    ) async throws -> T? {
        guard let result = try await find(moduleName: moduleName, itemName: itemName) else { return nil }
        return try await fetch(item: result.item, storage: result.storage)
    }
    
    /// Fetches a storage item after getting a module first
    /// - Parameters:
    ///     - moduleName: Module's name to fetch
    ///     - itemName: Storage item's name
    ///     - key: Key to use for fetching a storage item
    ///     - completion: Completion with either a generic `T` or `RpcError`
    public func fetch<T: Decodable>(
        moduleName: String,
        itemName: String,
        key: Data
    ) async throws -> T? {
        guard let result = try await find(moduleName: moduleName, itemName: itemName) else { return nil }
        return try await fetch(item: result.item, key: key, storage: result.storage)
    }
    
    /// Fetches a storage item after getting a module first
    /// - Parameters:
    ///     - moduleName: Module's name to fetch
    ///     - itemName: Storage item's name
    ///     - keys: Keys to use for fetching a storage item
    ///     - completion: Completion with either a generic `T` or `RpcError`
    public func fetch<T: Decodable>(
        moduleName: String,
        itemName: String,
        keys: [Data]
    ) async throws -> T? {
        guard let result = try await find(moduleName: moduleName, itemName: itemName) else { return nil }
        return try await fetch(item: result.item, keys: keys, storage: result.storage)
    }
    
    /// Fetches storage item from a specified storage
    ///  - Parameters:
    ///     - item: An item to be hashed
    ///     - storage: Storage for which a storage hasher is created, which hashes the item
    ///     - completion: Completion with either a generic `T` or `RpcError`
    public func fetch<T: Decodable>(
        item: RuntimeModuleStorageItem,
        storage: RuntimeModuleStorage
    ) async throws -> T? {
        try await stateRpc?.fetchStorageItem(item: item, storage: storage)
    }
    
    /// Fetches storage item from a specified storage
    ///  - Parameters:
    ///     - item: An item to be hashed
    ///     - key: A key to be used when hashing in a storage hasher
    ///     - storage: Storage for which a storage hasher is created, which hashes the item
    ///     - completion: Completion with either a generic `T` or `RpcError`
    public func fetch<T: Decodable>(
        item: RuntimeModuleStorageItem,
        key: Data,
        storage: RuntimeModuleStorage
    ) async throws -> T? {
        try await stateRpc?.fetchStorageItem(item: item, key: key, storage: storage)
    }
    
    /// Fetches storage item from a specified storage
    ///  - Parameters:
    ///     - item: An item to be hashed
    ///     - keys: Keys to be used when hashing in a storage hasher
    ///     - storage: Storage for which a storage hasher is created, which hashes the item
    ///     - completion: Completion with either a generic `T` or `RpcError`
    public func fetch<T: Decodable>(
        item: RuntimeModuleStorageItem,
        keys: [Data],
        storage: RuntimeModuleStorage
    ) async throws -> T? {
        try await stateRpc?.fetchStorageItem(item: item, keys: keys, storage: storage)
    }
}
