import Foundation
import ScaleCodecSwift
import CommonSwift

/// Interface for getting Runtime metadata and fetching Storage Items
public protocol StateRpc: AnyObject {
    /// Gets runtime metadata
    /// - Returns: A runtime metadata
    func runtimeMetadata() async throws -> RuntimeMetadata?
    /// Fetches storage item
    /// - Parameters:
    ///     - item: An item to be hashed to get a key which can be used as `RpcRequest`'s parameters
    ///     - storage: Storage for which a storage hasher is created, which hashes the item
    /// - Returns: The result for type a generic type `T`
    func fetchStorageItem<T: Decodable>(
        item: RuntimeModuleStorageItem,
        storage: RuntimeModuleStorage
    ) async throws -> T?
    /// Fetches storage item
    /// - Parameters:
    ///     - item: An item to be hashed to get a key which can be used as `RpcRequest`'s parameters
    ///     - key: A key to be used when hashing in a storage hasher.
    ///     - storage: Storage for which the storage hasher is created, which hashes the item
    /// - Returns: The result for type a generic type `T`
    func fetchStorageItem<T: Decodable>(
        item: RuntimeModuleStorageItem,
        key: Data,
        storage: RuntimeModuleStorage
    ) async throws -> T?
    /// Fetches storage item
    /// - Parameters:
    ///     - item: An item to be hashed to get a key which can be used as `RpcRequest`'s parameters
    ///     - keys: Keys to be used when hashing in a storage hasher.
    ///     - storage: Storage for which the storage hasher is created, which hashes the item
    /// - Returns: The result for type a generic type `T`
    func fetchStorageItem<T: Decodable>(
        item: RuntimeModuleStorageItem,
        keys: [Data],
        storage: RuntimeModuleStorage
    ) async throws -> T?
}

/// State RPC client which handles fetching storage item and runtime metadata
final class StateRpcClient: StateRpc {
    weak var codec: ScaleCoder?
    weak var rpcClient: RpcClient?
    let hashersProvider: HashersProvider
    
    init(codec: ScaleCoder? = nil, rpcClient: RpcClient? = nil, hashersProvider: HashersProvider) {
        self.codec = codec
        self.rpcClient = rpcClient
        self.hashersProvider = hashersProvider
    }
    
    func runtimeMetadata() async throws -> RuntimeMetadata? {
        let metadataEncoded: String? = try await rpcClient?.sendRequest(method: "state_getMetadata")
        guard let metadataEncoded = try metadataEncoded?.hex.decode() else { return nil }
        
        return try codec?.decoder.decode(RuntimeMetadata.self, from: metadataEncoded)
    }
    
    func fetchStorageItem<T: Decodable>(
        item: RuntimeModuleStorageItem,
        storage: RuntimeModuleStorage
    ) async throws -> T? {
        let key = try hashersProvider.getStorageHasher(storage: storage).hash(storageItem: item, keys: [])
        return try await fetchStorageItem(key: key)
    }
    
    func fetchStorageItem<T: Decodable>(
        item: RuntimeModuleStorageItem,
        key: Data,
        storage: RuntimeModuleStorage
    ) async throws -> T? {
        let key = try hashersProvider.getStorageHasher(storage: storage).hash(storageItem: item, keys: [key])
        return try await fetchStorageItem(key: key)
    }
    
    func fetchStorageItem<T: Decodable>(
        item: RuntimeModuleStorageItem,
        keys: [Data],
        storage: RuntimeModuleStorage
    ) async throws -> T? {
        let key = try hashersProvider.getStorageHasher(storage: storage).hash(storageItem: item, keys: keys)
        return try await fetchStorageItem(key: key)
    }
    
    // MARK: - Private
    /// Fetches a storage item from by sending a request via `RpcClient`
    /// - Parameters:
    ///     - key: Key to be used as `RpcRequest`'s parameter after being encoded (with including its prefix)
    /// - Returns: The result of fetching a storage item of a generic type `T`
    private func fetchStorageItem<T: Decodable>(key: Data) async throws -> T? {
        let encoded: String? = try await rpcClient?.sendRequest([key.hex.encode(includePrefix: true)], method: "state_getStorage")
        guard let encoded = try encoded?.hex.decode() else { return nil }
        
        return try codec?.decoder.decode(T.self, from: encoded)
    }
}
