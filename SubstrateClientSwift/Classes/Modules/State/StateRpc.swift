import Foundation
import ScaleCodecSwift
import CommonSwift

/// Interface for getting Runtime metadata and fetching Storage Items
protocol StateRpc {
    /// Gets runtime metadata
    /// - Parameters:
    ///     - completion: A completion that returns either `RuntimeMetadata` or `RpcError`
    func getRuntimeMetadata(completion: @escaping (RuntimeMetadata?, RpcError?) -> Void)
    /// Fetches storage item
    /// - Parameters:
    ///     - item: An item to be hashed to get a key which can be used as `RpcRequest`'s parameters
    ///     - storage: Storage for which a storage hasher is created, which hashes the item
    ///     - completion: The result for type a generic type `T` or `RpcError`
    func fetchStorageItem<T: Decodable>(
        item: RuntimeModuleStorageItem,
        storage: RuntimeModuleStorage,
        completion: @escaping (T?, RpcError?) -> Void
    ) throws
    /// Fetches storage item
    /// - Parameters:
    ///     - item: An item to be hashed to get a key which can be used as `RpcRequest`'s parameters
    ///     - key: A key to be used when hashing in a storage hasher.
    ///     - storage: Storage for which the storage hasher is created, which hashes the item
    ///     - completion: The result for type a generic type `T` or `RpcError`
    func fetchStorageItem<T: Decodable>(
        item: RuntimeModuleStorageItem,
        key: Data,
        storage: RuntimeModuleStorage,
        completion: @escaping (T?, RpcError?) -> Void
    ) throws
    /// Fetches storage item
    /// - Parameters:
    ///     - item: An item to be hashed to get a key which can be used as `RpcRequest`'s parameters
    ///     - keys: Keys to be used when hashing in a storage hasher.
    ///     - storage: Storage for which the storage hasher is created, which hashes the item
    ///     - completion: The result for type a generic type `T` or `RpcError`
    func fetchStorageItem<T: Decodable>(
        item: RuntimeModuleStorageItem,
        keys: [Data],
        storage: RuntimeModuleStorage,
        completion: @escaping (T?, RpcError?) -> Void
    ) throws
}

/// State RPC client which handles fetching storage item and runtime metadata
struct StateRpcClient: StateRpc {
    let codec: ScaleCoder
    let rpcClient: RpcClient
    let hashersProvider: HashersProvider
    let clientQueue: DispatchQueue
    let innerQueue: DispatchQueue
    
    func getRuntimeMetadata(completion: @escaping (RuntimeMetadata?, RpcError?) -> Void) {
        rpcClient.sendRequest(method: "state_getMetadata") { (response: String?, error: RpcError?) in
            guard let result = response?.hex.decode() else {
                completion(nil, error)
                return
            }
            
            decode(from: result, completion: completion)
        }
    }
    
    func fetchStorageItem<T: Decodable>(
        item: RuntimeModuleStorageItem,
        storage: RuntimeModuleStorage,
        completion: @escaping (T?, RpcError?) -> Void
    ) throws {
        let key = try hashersProvider.getStorageHasher(storage: storage).hash(storageItem: item, keys: [])
        fetchStorageItem(key: key, completion: completion)
    }
    
    func fetchStorageItem<T: Decodable>(
        item: RuntimeModuleStorageItem,
        key: Data,
        storage: RuntimeModuleStorage,
        completion: @escaping (T?, RpcError?) -> Void
    ) throws {
        let key = try hashersProvider.getStorageHasher(storage: storage).hash(storageItem: item, keys: [key])
        fetchStorageItem(key: key, completion: completion)
    }
    
    func fetchStorageItem<T: Decodable>(
        item: RuntimeModuleStorageItem,
        keys: [Data],
        storage: RuntimeModuleStorage,
        completion: @escaping (T?, RpcError?) -> Void
    ) throws {
        let key = try hashersProvider.getStorageHasher(storage: storage).hash(storageItem: item, keys: keys)
        fetchStorageItem(key: key, completion: completion)
    }
    
    // MARK: - Private
    /// Fetches a storage item from by sending a request via `RpcClient`
    /// - Parameters:
    ///     - key: Key to be used as `RpcRequest`'s parameter after being encoded (with including its prefix)
    ///     - completion: The result of fetching a storage item. Can contain either a generic type of `T` or `RpcError`
    private func fetchStorageItem<T: Decodable>(key: Data, completion: @escaping (T?, RpcError?) -> Void) {
        let request = RpcRequest(
            id: 0,
            method: "state_getStorage",
            params: [key.hex.encode(includePrefix: true)]
        )
        
        rpcClient.send(request) { (response: RpcResponse<String>?, error: RpcError?) in
            guard let result = response?.result?.hex.decode() else {
                clientQueue.async {
                    completion(nil, error)
                }
                
                return
            }
            
            decode(from: result, completion: completion)
        }
    }
    
    /// Decodes the provided data
    /// - Parameters:
    ///     - data: `Data` to be decoded
    ///     - completion: The result of decoding the data. Can contain either a generic type of `T` or `RpcError`
    private func decode<T: Decodable>(from data: Data, completion: @escaping (T?, RpcError?) -> Void) {
        innerQueue.async {
            do {
                let result = try codec.decoder.decode(T.self, from: data)
                
                clientQueue.async {
                    completion(result, nil)
                }
            } catch let error {
                clientQueue.async {
                    completion(nil, .requestBodyEncodingError(error))
                }
            }
        }
    }
}
