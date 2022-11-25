import BigInt
import Foundation

struct RuntimeModule: Codable {
    let name: String
    let storage: RuntimeModuleStorage?
    let callIndex: BigUInt?
    let eventsIndex: BigUInt?
    let constants: [RuntimeModuleConstant]
    let errorsIndex: BigUInt?
    let index: UInt8
}
