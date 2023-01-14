import EncryptingSwift
import Foundation
import HashingSwift

/// An interface for fetching runtime version and account
public protocol SystemRpc: AnyObject {
    /// Gets runtime version
    /// - Parameters:
    ///     - completion: Completion with an optiional runtime version
    func runtimeVersion() async throws -> RuntimeVersion?
    /// Gets account
    /// - Parameters:
    ///     - completion: Completion with either an optional `Account` or with an optional `RpcError`
    func account(accountId: AccountId) async throws -> Account?
    func account(accountIdHex: String) async throws -> Account?
    func account(publicKey: Data) async throws -> Account?
    func account(publicKeyHex: String) async throws -> Account?
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
