import Foundation
import BigInt

/// An object holding information about a module
private struct ModulePath: Hashable {
    let moduleName: String
    let childName: String
}

/// Substrate lookup serivce
class SubstrateLookupService {
    enum Error: Swift.Error {
        case noRuntimeMetadata
    }
    
    weak var runtimeMetadata: RuntimeMetadata?
    private let namingPolicy: SubstrateClientNamingPolicy
    
    // MARK: - Caches
    private var modulesCache: [String: RuntimeModule] = [:]
    private var constantsCache: [ModulePath: RuntimeModuleConstant] = [:]
    private var storageItemsCache: [ModulePath: RuntimeModuleStorageItem] = [:]
    
    /// Creates a substrate lookup serivce
    /// - Parameters:
    ///     - runtimeMetadata: A `PassthroughSubject` which holds an optional `RuntimeMetadata`
    ///     - namingPolicy: Naming policy
    init(namingPolicy: SubstrateClientNamingPolicy) {
        self.namingPolicy = namingPolicy
    }
    
    // MARK: - Finding Constant
    /// Finds constant with the provided name either in cache or in a runtime module
    /// - Parameters:
    ///     - module: Runtime module to search in if in the constants' cache the constant can not be found
    ///     - name: The name of the constant to be searched by
    /// - Returns: Found runtime module constant
    private func findConstant(module: RuntimeModule, name: String) -> RuntimeModuleConstant? {
        let constantPath = ModulePath(moduleName: module.name, childName: name)
        let constant = constantsCache[constantPath] ?? module.constants.first(where: { $0.name == name })
        constantsCache[constantPath] = constant
        
        return constant
    }
    
    /// Finds constant with the provided name either in a runtime module after finding the module first
    /// - Parameters:
    ///     - moduleName: Runtime module to search in
    ///     - constantName: The name of the constant to be searched by
    /// - Returns: Found runtime module constant
    func findConstant(
        moduleName: String,
        constantName: String
    ) throws -> RuntimeModuleConstant? {
        guard let module = self.getModule(name: moduleName, from: runtimeMetadata) else {
            return nil
        }
        
        return findConstant(module: module, name: constantName)
    }
    
    /// Finds a runtime lookup item for a provided index
    /// - Parameters:
    ///     - index: Index for which a runtime lookup item should be found
    /// - Returns: An optional runtime lookup item
    func findRuntimeItem(index: BigUInt) -> RuntimeType? {
        findRuntimeType(index: index)
    }
    
    /// Finds a runtime module for a provided name using the existing runtime metadata
    /// - Parameters:
    ///     - name: The name under which a runtime module should be found
    /// - Returns: An optional runtime module for a specific name
    func findModule(name: String) -> RuntimeModule? {
        getModule(name: name, from: runtimeMetadata)
    }
    
    // MARK: - Private
    /// Returns the currrent runtime metadata
    /// - Returns: Found runtime module
    private func tryRuntimeMetadata() throws -> RuntimeMetadata {
        guard let runtimeMetadata = runtimeMetadata else {
            throw Error.noRuntimeMetadata
        }
        
        return runtimeMetadata
    }
    
    // Finds a runtime module for a provided name
    /// - Parameters:
    ///     - name: The name to find a module for
    ///     - metadata: Metadata modules of which should be searched
    /// - Returns: Found runtime module
    private func getModule(name: String, from metadata: RuntimeMetadata?) -> RuntimeModule? {
        if let module = self.modulesCache[name] {
            return module
        }
        
        let module = metadata?.modules.first(where: { self.equals(lhs: $0.name, rhs: name) })
        if module != nil {
            self.modulesCache[name] = module
        }
        
        return module
    }
    
    /// Compares Strings either lowercasing them or not based on a naming policy
    /// - Parameters:
    ///     - lhs: The first string
    ///     - rhs: The second string
    /// - Returns: A `Bool` after comparing the strings
    private func equals(lhs: String, rhs: String) -> Bool {
        switch namingPolicy {
        case .none:
            return lhs == rhs
        case .caseInsensitive:
            return lhs.lowercased() == rhs.lowercased()
        }
    }
    
    /// Finds the storage item in a module by its name
    /// - Parameters:
    ///     - module: The module to use for searching the storage item
    ///     - name: The module's child's name
    /// - Returns: A storage item in a module
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
            storageItem = module.storage?.items.first { [weak self] in
                guard let `self` = self else { return false }
                return self.equals(lhs: $0.name, rhs: name)
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
    func findStorageItem(
        moduleName: String,
        itemName: String
    ) throws -> FindStorageItemResult? {
        let runtimeMetadata = try tryRuntimeMetadata()
        
        guard let module = self.getModule(name: moduleName, from: runtimeMetadata) else {
            return nil
        }
        
        return findStorageItem(module: module, name: itemName)
    }
    
    /// Finds a runtime lookup item for a provided index
    /// - Parameters:
    ///     - index: Index for which a runtime lookup item should be found
    /// - Returns: An optional runtime lookup item
    private func findRuntimeType(index: BigUInt) -> RuntimeType? {
        runtimeMetadata?.lookup.findItemByIndex(index)
    }
}

/// A wrapper over runtime module storage item and runtime module storage itself
struct FindStorageItemResult: Codable {
    let item: RuntimeModuleStorageItem?
    let storage: RuntimeModuleStorage
}
