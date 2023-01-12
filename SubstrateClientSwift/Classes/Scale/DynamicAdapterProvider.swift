import BigInt
import Foundation
import ScaleCodecSwift

// MARK: - Adapter

protocol AdapterProtocol {
    var scaleAdapter: ScaleCodecAdaptable { get }
    func toData(value: Any) -> Data?
    func fromData(_ data: Data) -> Any?
}

final class Adapter<T>: AdapterProtocol {
    let scaleAdapter: ScaleCodecAdaptable
    let toDataClosure: ((T) -> Data)?
    let fromDataClosure: ((Data) -> T)?
    
    init(
        scaleAdapter: ScaleCodecAdapter<T>,
        toDataClosure: ((T) -> Data)? = nil,
        fromDataClosure: ((Data) -> T)? = nil
    ) {
        self.scaleAdapter = scaleAdapter
        self.toDataClosure = toDataClosure
        self.fromDataClosure = fromDataClosure
    }

    func toData(value: Any) -> Data? {
        guard let value = value as? T else { return nil }
        
        return toDataClosure?(value)
    }
    
    func fromData(_ data: Data) -> Any? {
        fromDataClosure?(data)
    }
}

final class DynamicAdapterProvider {
    // MARK: - Dependencies
    
    let coder: ScaleCoder
    weak var runtimeMetadataProvider: RuntimeMetadataProvider?
    
    init(coder: ScaleCoder, runtimeMetadataProvider: RuntimeMetadataProvider) {
        self.coder = coder
        self.runtimeMetadataProvider = runtimeMetadataProvider
    }
    
    // MARK: -
    
    func adapterProvider(for type: DynamicType.Type) throws -> AdapterProtocol {
        guard let runtimeMetadata = runtimeMetadataProvider?.runtimeSync() else {
            // In fact, this should only happen upon the substrate client deallocation, so it's safe
            throw DynamicAdapterError.internalFailure
        }
        
        guard let typeDef: RuntimeTypeDef = runtimeMetadata.lookup.findItemByIndex(type.lookupIndex)?.def else {
            throw DynamicAdapterError.typeIsNotFoundInRuntimeMetadataException
        }
        
        switch typeDef {
        case .composite:
            throw DynamicAdapterError.unsupportedDynamicTypeException
        case .variant:
            throw DynamicAdapterError.unsupportedDynamicTypeException
        case .sequence:
            throw DynamicAdapterError.unsupportedDynamicTypeException
        case .array:
            throw DynamicAdapterError.unsupportedDynamicTypeException
        case .tuple:
            throw DynamicAdapterError.unsupportedDynamicTypeException
        case .primitive(let runtimeTypeDefPrimitive):
            return try findAdapter(primitive: runtimeTypeDefPrimitive)
        case .compact:
            return Adapter(
                scaleAdapter: BigUIntAdapter(coder: coder),
                toDataClosure: { Data($0.serialize().reversed()) },
                fromDataClosure: { .init(Data($0.reversed())) }
            )
        case .bitSequence:
            throw DynamicAdapterError.unsupportedDynamicTypeException
        }
    }
    
    private func findAdapter(primitive: RuntimeTypeDefPrimitive) throws -> AdapterProtocol {
        switch primitive {
        case .bool:
            return Adapter(scaleAdapter: BoolAdapter())
        case .char:
            throw DynamicAdapterError.unsupportedDynamicTypeException
        case .string:
            return Adapter(scaleAdapter: StringAdapter(coder: coder))
        case .uint8:
            return Adapter(
                scaleAdapter: NumericAdapter<UInt8>(),
                toDataClosure: { NumericAdapter.toData($0) },
                fromDataClosure: { NumericAdapter.fromData($0) }
            )
        case .uint16:
            return Adapter(
                scaleAdapter: NumericAdapter<UInt16>(),
                toDataClosure: { NumericAdapter.toData($0) },
                fromDataClosure: { NumericAdapter.fromData($0) }
            )
        case .uint32:
            return Adapter(
                scaleAdapter: NumericAdapter<UInt32>(),
                toDataClosure: { NumericAdapter.toData($0) },
                fromDataClosure: { NumericAdapter.fromData($0) }
            )
        case .uint64:
            return Adapter(
                scaleAdapter: NumericAdapter<UInt64>(),
                toDataClosure: { NumericAdapter.toData($0) },
                fromDataClosure: { NumericAdapter.fromData($0) }
            )
        case .uint128:
            return Adapter(
                scaleAdapter: UInt128Adapter(),
                toDataClosure: { $0.data() },
                fromDataClosure: { $0.uInt128() }
            )
        case .uint256:
            return Adapter(
                scaleAdapter: UInt256Adapter(),
                toDataClosure: { $0.data() },
                fromDataClosure: { $0.uInt256() }
            )
        case .int8:
            return Adapter(
                scaleAdapter: NumericAdapter<Int8>(),
                toDataClosure: { NumericAdapter.toData($0) },
                fromDataClosure: { NumericAdapter.fromData($0) }
            )
        case .int16:
            return Adapter(
                scaleAdapter: NumericAdapter<Int16>(),
                toDataClosure: { NumericAdapter.toData($0) },
                fromDataClosure: { NumericAdapter.fromData($0) }
            )
        case .int32:
            return Adapter(
                scaleAdapter: NumericAdapter<Int32>(),
                toDataClosure: { NumericAdapter.toData($0) },
                fromDataClosure: { NumericAdapter.fromData($0) }
            )
        case .int64:
            return Adapter(
                scaleAdapter: NumericAdapter<Int64>(),
                toDataClosure: { NumericAdapter.toData($0) },
                fromDataClosure: { NumericAdapter.fromData($0) }
            )
        case .int128:
            return Adapter(
                scaleAdapter: Int128Adapter(),
                toDataClosure: { $0.data() },
                fromDataClosure: { $0.int128() }
            )
        case .int256:
            return Adapter(
                scaleAdapter: Int256Adapter(),
                toDataClosure: { $0.data() },
                fromDataClosure: { $0.int256() }
            )
        }
    }
}
