/**
 *
 * Copyright 2023 SUBSTRATE LABORATORY LLC <info@sublab.dev>
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0

 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 * 
 */

import Foundation
import ScaleCodecSwift

// MARK: - Protocol

/// An interface for substrate storage service
public protocol SubstrateStorage: AnyObject {
    /// Finds a storage item result, which is a wrapper over runtime module storage item and runtime module storage itself,
    /// by previously fetching the module
    /// - Parameters:
    ///     - moduleName: Module's name to fetch
    ///     - itemName: Storage item's name
    /// - Returns: A storage item result from a module
    func find(moduleName: String, itemName: String) async throws -> FindStorageItemResult?
    
    /// Fetches a storage item after getting a module first
    /// - Parameters:
    ///     - moduleName: Module's name to fetch
    ///     - itemName: Storage item's name
    /// - Returns: A generic storage item of type `T`
    func fetch<T: Decodable>(
        moduleName: String,
        itemName: String
    ) async throws -> T?
    
    /// Fetches a storage item after getting a module first
    /// - Parameters:
    ///     - moduleName: Module's name to fetch
    ///     - itemName: Storage item's name
    ///     - key: Key to use for fetching a storage item
    /// - Returns: A generic storage item of type `T`
    func fetch<T: Decodable>(
        moduleName: String,
        itemName: String,
        key: Data
    ) async throws -> T?
    
    /// Fetches a storage item after getting a module first
    /// - Parameters:
    ///     - moduleName: Module's name to fetch
    ///     - itemName: Storage item's name
    ///     - keys: Keys to use for fetching a storage item
    /// - Returns: A generic storage item of type `T`
    func fetch<T: Decodable>(
        moduleName: String,
        itemName: String,
        keys: [Data]
    ) async throws -> T?
    
    /// Fetches storage item from a specified storage
    /// - Parameters:
    ///     - item: An item to be hashed
    ///     - storage: Storage for which a storage hasher is created, which hashes the item
    /// - Returns: A generic storage item of type T
    func fetch<T: Decodable>(
        item: RuntimeModuleStorageItem,
        storage: RuntimeModuleStorage
    ) async throws -> T?
    
    /// Fetches storage item from a specified storage
    /// - Parameters:
    ///     - item: An item to be hashed
    ///     - key: A key to be used when hashing in a storage hasher
    ///     - storage: Storage for which a storage hasher is created, which hashes the item
    /// - Returns: A generic storage item of type `T`
    func fetch<T: Decodable>(
        item: RuntimeModuleStorageItem,
        key: Data,
        storage: RuntimeModuleStorage
    ) async throws -> T?
    
    /// Fetches storage item from a specified storage
    /// - Parameters:
    ///     - item: An item to be hashed
    ///     - keys: Keys to be used when hashing in a storage hasher
    ///     - storage: Storage for which a storage hasher is created, which hashes the item
    /// - Returns: A generic storage item of type `T`
    func fetch<T: Decodable>(
        item: RuntimeModuleStorageItem,
        keys: [Data],
        storage: RuntimeModuleStorage
    ) async throws -> T?
}

// MARK: - Implementation

/// Substrate storage service
public final class SubstrateStorageService: SubstrateStorage {
    private weak var lookup: SubstrateLookup?
    private weak var stateRpc: StateModule?
    
    /// Creates a substrate storage service
    /// - Parameters:
    ///     - lookup: Substrate lookup serivce
    ///     - stateRpc: An interface for getting Runtime metadata and fetching Storage Items
    ///     - clientQueue: A client-specified queue on which fetched data will be returned. The default one is `main`
    ///     - innerQueue: An inner queue on which the logic takes place
    init(
        lookup: SubstrateLookup?,
        stateRpc: StateModule?
    ) {
        self.lookup = lookup
        self.stateRpc = stateRpc
    }
    
    public func find(moduleName: String, itemName: String) async throws -> FindStorageItemResult? {
        try await lookup?.findStorageItem(moduleName: moduleName, itemName: itemName)
    }
    
    public func fetch<T: Decodable>(
        moduleName: String,
        itemName: String
    ) async throws -> T? {
        guard let result = try await find(moduleName: moduleName, itemName: itemName) else { return nil }
        return try await fetch(item: result.item, storage: result.storage)
    }
    
    public func fetch<T: Decodable>(
        moduleName: String,
        itemName: String,
        key: Data
    ) async throws -> T? {
        guard let result = try await find(moduleName: moduleName, itemName: itemName) else { return nil }
        return try await fetch(item: result.item, key: key, storage: result.storage)
    }
    
    public func fetch<T: Decodable>(
        moduleName: String,
        itemName: String,
        keys: [Data]
    ) async throws -> T? {
        guard let result = try await find(moduleName: moduleName, itemName: itemName) else { return nil }
        return try await fetch(item: result.item, keys: keys, storage: result.storage)
    }
    
    public func fetch<T: Decodable>(
        item: RuntimeModuleStorageItem,
        storage: RuntimeModuleStorage
    ) async throws -> T? {
        try await stateRpc?.fetchStorageItem(item: item, storage: storage)
    }
    
    public func fetch<T: Decodable>(
        item: RuntimeModuleStorageItem,
        key: Data,
        storage: RuntimeModuleStorage
    ) async throws -> T? {
        try await stateRpc?.fetchStorageItem(item: item, key: key, storage: storage)
    }
    
    public func fetch<T: Decodable>(
        item: RuntimeModuleStorageItem,
        keys: [Data],
        storage: RuntimeModuleStorage
    ) async throws -> T? {
        try await stateRpc?.fetchStorageItem(item: item, keys: keys, storage: storage)
    }
}
