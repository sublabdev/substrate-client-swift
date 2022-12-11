import Foundation

/// An object holding information about a module
private struct ModulePath: Hashable {
    let moduleName: String
    let childName: String
}

/// Substrate lookup serivce
class SubstrateLookupService {
    private var runtimeMetadata: RuntimeMetadata?
    private let namingPolicy: SubstrateClientNamingPolicy
    
    // MARK: - Caches
    private var modulesCache: [String: RuntimeModule] = [:]
    private var constantsCache: [ModulePath: RuntimeModuleConstant] = [:]
    private var storageItemsCache: [ModulePath: RuntimeModuleStorageItem] = [:]
    
    /// Creates a substrate lookup serivce
    /// - Parameters:
    ///     - runtimeMetadata: A `PassthroughSubject` which holds an optional `RuntimeMetadata`
    ///     - namingPolicy: Naming policy
    init(
        runtimeMetadata: RuntimeMetadata?,
        namingPolicy: SubstrateClientNamingPolicy
    ) {
        self.runtimeMetadata = runtimeMetadata
        self.namingPolicy = namingPolicy
    }
    
    /// Updates the runtime metadata in the lookup service
    /// - Parameters:
    ///     - runtimeMetadata: A runtime metadata to update with the existing one
    func updateLookupService(with runtimeMetadata: RuntimeMetadata?) {
        self.runtimeMetadata = runtimeMetadata
    }
    
    /// Finds a runtime module for a provided name
    /// - Parameters:
    ///     - name: The name to find a module for
    /// - Returns: Found runtime module
    func findModule(name: String) -> RuntimeModule? {
        if let module = self.modulesCache[name] {
            return module
        }
        
        let module = runtimeMetadata?.modules.first(where: { self.equals(lhs: $0.name, rhs: name) })
        if module != nil {
            self.modulesCache[name] = module
        }
        
        return module
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
    ) -> RuntimeModuleConstant? {
        guard let module = findModule(name: moduleName) else { return nil }
        
        return findConstant(module: module, name: constantName)
    }
    
    // MARK: - Private
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
    /// - Returns: Found storage item or nil
    func findStorageItem(module: RuntimeModule, name: String) -> FindStorageItemResult? {
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
    ) -> FindStorageItemResult? {
        guard let module = findModule(name: moduleName) else { return nil }
        return findStorageItem(module: module, name: itemName)
    }
}

/// A wrapper over runtime module storage item and runtime module storage itself
struct FindStorageItemResult: Codable {
    let item: RuntimeModuleStorageItem?
    let storage: RuntimeModuleStorage
}
