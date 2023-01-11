import BigInt
import Foundation

/// Runtime module
public class RuntimeModule: Codable {
    public let name: String
    public let storage: RuntimeModuleStorage?
    public let callIndex: BigUInt?
    public let eventsIndex: BigUInt?
    public let constants: [RuntimeModuleConstant]
    public let errorsIndex: BigUInt?
    public let index: UInt8
    
    public init(
        name: String,
        storage: RuntimeModuleStorage?,
        callIndex: BigUInt?,
        eventsIndex: BigUInt?,
        constants: [RuntimeModuleConstant],
        errorsIndex: BigUInt?,
        index: UInt8
    ) {
        self.name = name
        self.storage = storage
        self.callIndex = callIndex
        self.eventsIndex = eventsIndex
        self.constants = constants
        self.errorsIndex = errorsIndex
        self.index = index
    }
}
