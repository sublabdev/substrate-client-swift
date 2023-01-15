import EncryptingSwift
import Foundation
import HashingSwift

/// An interface for fetching runtime version and account
public protocol SystemRpc: AnyObject {
    /// Gets runtime version
    /// - Returns: An optiional runtime version
    func runtimeVersion() async throws -> RuntimeVersion?
    
    /// Gets account using account ID
    /// - Parameters:
    ///     - accountId: An account ID used to find the account
    /// - Returns: An optional `Account`
    func account(accountId: AccountId) async throws -> Account?
    
    /// Gets account using account ID's hex
    /// - Parameters:
    ///     - accountIdHex: An account ID's hex used to find the account
    /// - Returns: An optional `Account`
    func account(accountIdHex: String) async throws -> Account?
    
    /// Gets account using public key
    /// - Parameters:
    ///     - publicKey: A public key used to find the account
    /// - Returns: An optional `Account`
    func account(publicKey: Data) async throws -> Account?
    
    /// Gets account using public key's hex
    /// - Parameters:
    ///     - publicKeyHex: A public key's hex used to find the account
    /// - Returns: An optional `Account`
    func account(publicKeyHex: String) async throws -> Account?
    
    /// Gets account using a keypair with public and private keys
    /// - Parameters:
    ///     - keyPair: A keypair with public and private keys
    /// - Returns: An optional `Account`
    func account(keyPair: KeyPair) async throws -> Account?
}

final class SystemRpcClient: SystemRpc {
    enum Error: Swift.Error {
        case hexDecodeFailed
    }
    
    private weak var constants: SubstrateConstantsService?
    private weak var storage: SubstrateStorageService?
    
    init(constants: SubstrateConstantsService?, storage: SubstrateStorageService?) {
        self.constants = constants
        self.storage = storage
    }
    
    func runtimeVersion() async throws -> RuntimeVersion? {
        try await constants?.fetch(moduleName: "system", constantName: "version")
    }
    
    func account(accountId: AccountId) async throws -> Account? {
        try await storage?.fetch(moduleName: "system", itemName: "account", key: accountId)
    }
    
    func account(accountIdHex: String) async throws -> Account? {
        try await account(accountId: try accountIdHex.hex.decode())
    }
    
    func account(publicKey: Data) async throws -> Account? {
        try await account(accountId: publicKey.ss58.accountId())
    }
    
    func account(publicKeyHex: String) async throws -> Account? {
        try await account(publicKey: publicKeyHex.hex.decode())
    }
    
    func account(keyPair: EncryptingSwift.KeyPair) async throws -> Account? {
        try await account(publicKey: keyPair.publicKey)
    }
}
