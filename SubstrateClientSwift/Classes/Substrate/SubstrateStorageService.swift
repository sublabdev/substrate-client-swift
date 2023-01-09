import Foundation
import ScaleCodecSwift

/// Substrate storage service
class SubstrateStorageService {
    private let lookup: SubstrateLookupService
    private let stateRpc: StateRpc
    private let clientQueue: DispatchQueue
    private let innerQueue: DispatchQueue
    
    /// Creates a substrate storage service
    /// - Parameters:
    ///     - lookup: Substrate lookup serivce
    ///     - stateRpc: An interface for getting Runtime metadata and fetching Storage Items
    ///     - clientQueue: A client-specified queue on which fetched data will be returned. The default one is `main`
    ///     - innerQueue: An inner queue on which the logic takes place
    init(
        lookup: SubstrateLookupService,
        stateRpc: StateRpc,
        clientQueue: DispatchQueue,
        innerQueue: DispatchQueue
    ) {
        self.lookup = lookup
        self.stateRpc = stateRpc
        self.clientQueue = clientQueue
        self.innerQueue = innerQueue
    }
    
    /// Finds a storage item result, which is a wrapper over runtime module storage item and runtime module storage itself,
    /// by previously fetching the module
    /// - Parameters:
    ///     - moduleName: Module's name to fetch
    ///     - itemName: Storage item's name
    /// - Returns: A storage item result from a module
    func find(moduleName: String, itemName: String) throws -> FindStorageItemResult? {
        try lookup.findStorageItem(moduleName: moduleName, itemName: itemName)
    }

    /// Fetches a storage item after getting a module first
    /// - Parameters:
    ///     - moduleName: Module's name to fetch
    ///     - itemName: Storage item's name
    ///     - completion: Completion with either a generic `T` or `RpcError`
    func fetch<T: Decodable>(
        moduleName: String,
        itemName: String,
        completion: @escaping(T?, RpcError?) -> Void
    ) {
        do {
            guard let storageItemResult = try find(moduleName: moduleName, itemName: itemName) else {
                clientQueue.async {
                    completion(nil, .responseError(.noData))
                }
                
                return
            }
            
            handleFetchingStorageItem(from: storageItemResult, completion: completion)
        } catch {
            clientQueue.async {
                completion(nil, .responseError(.noData))
            }
        }
    }
    
    /// Fetches a storage item after getting a module first
    /// - Parameters:
    ///     - moduleName: Module's name to fetch
    ///     - itemName: Storage item's name
    ///     - key: Key to use for fetching a storage item
    ///     - completion: Completion with either a generic `T` or `RpcError`
    func fetch<T: Decodable>(
        moduleName: String,
        itemName: String,
        key: Data,
        completion: @escaping(T?, RpcError?) -> Void
    ) {
        do {
            guard let storageItemResult = try find(moduleName: moduleName, itemName: itemName) else {
                clientQueue.async {
                    completion(nil, .responseError(.noData))
                }
                
                return
            }
            
            handleFetchingStorageItem(from: storageItemResult, key: key, completion: completion)
        } catch {
            clientQueue.async {
                completion(nil, .responseError(.noData))
            }
        }
    }
    
    /// Fetches a storage item after getting a module first
    /// - Parameters:
    ///     - moduleName: Module's name to fetch
    ///     - itemName: Storage item's name
    ///     - keys: Keys to use for fetching a storage item
    ///     - completion: Completion with either a generic `T` or `RpcError`
    func fetch<T: Decodable>(
        moduleName: String,
        itemName: String,
        keys: [Data],
        completion: @escaping(T?, RpcError?) -> Void
    ) {
        do {
            guard let storageItemResult = try find(moduleName: moduleName, itemName: itemName) else {
                clientQueue.async {
                    completion(nil, .responseError(.noData))
                }
                
                return
            }
            
            handleFetchingStorageItem(from: storageItemResult, keys: keys, completion: completion)
        } catch {
            clientQueue.async {
                completion(nil, .responseError(.noData))
            }
        }
    }
    
    /// Fetches storage item from a specified storage
    ///  - Parameters:
    ///     - item: An item to be hashed
    ///     - storage: Storage for which a storage hasher is created, which hashes the item
    ///     - completion: Completion with either a generic `T` or `RpcError`
    func fetch<T: Decodable>(
        item: RuntimeModuleStorageItem,
        storage: RuntimeModuleStorage,
        completion: @escaping (T?, RpcError?) -> Void
    ) throws {
        try stateRpc.fetchStorageItem(item: item, storage: storage, completion: completion)
    }
    
    /// Fetches storage item from a specified storage
    ///  - Parameters:
    ///     - item: An item to be hashed
    ///     - key: A key to be used when hashing in a storage hasher
    ///     - storage: Storage for which a storage hasher is created, which hashes the item
    ///     - completion: Completion with either a generic `T` or `RpcError`
    func fetch<T: Decodable>(
        item: RuntimeModuleStorageItem,
        key: Data,
        storage: RuntimeModuleStorage,
        completion: @escaping (T?, RpcError?) -> Void
    ) throws {
        try stateRpc.fetchStorageItem(item: item, key: key, storage: storage, completion: completion)
    }
    
    /// Fetches storage item from a specified storage
    ///  - Parameters:
    ///     - item: An item to be hashed
    ///     - keys: Keys to be used when hashing in a storage hasher
    ///     - storage: Storage for which a storage hasher is created, which hashes the item
    ///     - completion: Completion with either a generic `T` or `RpcError`
    func fetch<T: Decodable>(
        item: RuntimeModuleStorageItem,
        keys: [Data],
        storage: RuntimeModuleStorage,
        completion: @escaping (T?, RpcError?) -> Void
    ) throws {
        try stateRpc.fetchStorageItem(item: item, keys: keys, storage: storage, completion: completion)
    }
    
    // MARK: - Private
    
    /// Handles fetching storage item from a `FindStorageItemResult`
    ///  - Parameters:
    ///     - findStorageItemResult: The `findStorageItemResult` object
    ///     - key: Key to use for fetching a storage item
    ///     - keys: Keys to use for fetching a storage item result
    ///     - completion: The completion with either a generic type `T` or `RpcError`
    private func handleFetchingStorageItem<T: Decodable>(
        from findStorageItemResult: FindStorageItemResult?,
        key: Data? = nil,
        keys: [Data]? = nil,
        completion: @escaping(T?, RpcError?) -> Void
    ) {
        guard let result = findStorageItemResult, let item = result.item else {
            clientQueue.async {
                completion(nil, .responseError(.noData))
            }
            
            return
        }
        
        do {
            if let key = key {
                try stateRpc.fetchStorageItem(item: item, key: key, storage: result.storage, completion: completion)
            } else if let keys = keys {
                try stateRpc.fetchStorageItem(item: item, keys: keys, storage: result.storage, completion: completion)
            } else {
                try stateRpc.fetchStorageItem(item: item, storage: result.storage, completion: completion)
            }
        } catch {
            clientQueue.async {
                completion(nil, .responseError(.noData))
            }
        }
    }
}
