import BigInt
import Foundation

/// Runtime module
public class RuntimeModule: Codable {
    let name: String
    let storage: RuntimeModuleStorage?
    let callIndex: BigUInt?
    let eventsIndex: BigUInt?
    let constants: [RuntimeModuleConstant]
    let errorsIndex: BigUInt?
    let index: UInt8
    
    init(
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
