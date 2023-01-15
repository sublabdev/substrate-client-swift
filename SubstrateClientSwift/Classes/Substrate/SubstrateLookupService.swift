import Foundation
import BigInt

/// An object holding information about a module
private struct ModulePath: Hashable {
    let moduleName: String
    let childName: String
}

/// An interface for substrate lookup
public protocol SubstrateLookup: AnyObject {
    /// Finds a runtime lookup item for a provided index
    /// - Parameters:
    ///     - index: Index for which a runtime lookup item should be found
    /// - Returns: An optional runtime lookup item
    func findRuntimeItem(index: BigUInt) async throws -> RuntimeType?
    
    /// Finds a runtime lookup item for a provided index
    /// - Parameters:
    ///     - index: Index for which a runtime lookup item should be found
    /// - Returns: An optional runtime lookup item
    func findRuntimeType(index: BigUInt) async throws -> RuntimeType?
    
    /// Finds a runtime module for a provided name
    /// - Parameters:
    ///     - name: The name to find a module for
    /// - Returns: Found runtime module
    func module(name: String) async throws -> RuntimeModule?
    
    /// Finds constant with the provided name either in cache or in a runtime module
    /// - Parameters:
    ///     - module: Runtime module to search in if in the constants' cache the constant can not be found
    ///     - name: The name of the constant to be searched by
    /// - Returns: Found runtime module constant
    func findConstant(
        moduleName: String,
        constantName: String
    ) async throws -> RuntimeModuleConstant?
    
    /// Finds the storage item in a module by its name
    /// - Parameters:
    ///     - module: The module to use for searching the storage item
    ///     - name: The module's child's name
    /// - Returns: A storage item in a module
    func findStorageItem(
        moduleName: String,
        itemName: String
    ) async throws -> FindStorageItemResult?
}

protocol InternalSubstrateLookup: SubstrateLookup {
    var runtimeMetadataProvider: RuntimeMetadataProvider? { get set }
}

/// Substrate lookup serivce
final class SubstrateLookupService: InternalSubstrateLookup {
    enum Error: Swift.Error {
        case noRuntimeMetadataProvider
    }
    
    weak var runtimeMetadataProvider: RuntimeMetadataProvider?
    private func runtimeMetadata() async throws -> RuntimeMetadata {
        guard let provider = runtimeMetadataProvider else {
            throw Error.noRuntimeMetadataProvider
        }
        
        return try await provider.runtimeMetadata()
    }
    
    private let namingPolicy: SubstrateClientNamingPolicy
    
    // MARK: - Caches
    
    private var modulesCache: [String: RuntimeModule] = [:]
    private var constantsCache: [ModulePath: RuntimeModuleConstant] = [:]
    private var storageItemsCache: [ModulePath: RuntimeModuleStorageItem] = [:]
    
    /// Creates a substrate lookup serivce
    /// - Parameters:
    ///     - namingPolicy: Naming policy
    init(namingPolicy: SubstrateClientNamingPolicy) {
        self.namingPolicy = namingPolicy
    }
}

// MARK: - Lookup by index

extension SubstrateLookupService {
    public func findRuntimeItem(index: BigUInt) async throws -> RuntimeType? {
        try await findRuntimeType(index: index)
    }
    
    public func findRuntimeType(index: BigUInt) async throws -> RuntimeType? {
        try await runtimeMetadata().lookup.findItem(by: index)
    }
}

// MARK: - Modules lookup

extension SubstrateLookupService {
    public func module(name: String) async throws -> RuntimeModule? {
        if let module = self.modulesCache[name] {
            return module
        }
        
        let module = try await runtimeMetadata().modules.first(where: { namingPolicy.equals($0.name, name) })
        if module != nil {
            self.modulesCache[name] = module
        }
        
        return module
    }
}

// MARK: - Constants lookup

extension SubstrateLookupService {
    private func findConstant(module: RuntimeModule, name: String) -> RuntimeModuleConstant? {
        let constantPath = ModulePath(moduleName: module.name, childName: name)
        let constant = constantsCache[constantPath] ?? module.constants.first(where: { namingPolicy.equals($0.name, name) })
        constantsCache[constantPath] = constant
        
        return constant
    }
    
    /// Finds constant with the provided name either in a runtime module after finding the module first
    /// - Parameters:
    ///     - moduleName: Runtime module to search in
    ///     - constantName: The name of the constant to be searched by
    /// - Returns: Found runtime module constant
    public func findConstant(
        moduleName: String,
        constantName: String
    ) async throws -> RuntimeModuleConstant? {
        guard let module = try await module(name: moduleName) else {
            return nil
        }
        
        return findConstant(module: module, name: constantName)
    }
}

// MARK: - Storage lookup

/// Storage item result
public struct FindStorageItemResult: Codable {
    public let item: RuntimeModuleStorageItem
    public let storage: RuntimeModuleStorage
}

extension SubstrateLookupService {
    private func findStorageItem(
        module: RuntimeModule,
        name: String
    ) -> FindStorageItemResult? {
        let constantPath = ModulePath(moduleName: module.name, childName: name)
        guard let storage = module.storage else { return nil }
        
        var storageItem: RuntimeModuleStorageItem?
        
        if let cachedItem = storageItemsCache[constantPath] {
            storageItem = cachedItem
        } else {
            storageItem = module.storage?.items.first {
                namingPolicy.equals($0.name, name)
            }
        }
        
        guard let item = storageItem else { return nil }
        
        storageItemsCache[constantPath] = item

        return FindStorageItemResult(item: item, storage: storage)
    }
    
    /// Finds a storage item previously fetching the module
    /// - Parameters:
    ///     - moduleName: Module's name to fetch
    ///     - itemName: Storage item's name
    /// - Returns: An optional storage item result
    public func findStorageItem(
        moduleName: String,
        itemName: String
    ) async throws -> FindStorageItemResult? {
        guard let module = try await module(name: moduleName) else {
            return nil
        }
        
        return findStorageItem(module: module, name: itemName)
    }
}
