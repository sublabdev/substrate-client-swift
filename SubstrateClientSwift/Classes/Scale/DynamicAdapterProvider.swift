import BigInt
import Foundation
import ScaleCodecSwift

// MARK: - Adapter

/// An interface for providing a scale codec adapter as well as methods for decoding and encoding
protocol AdapterProtocol {
    var scaleAdapter: ScaleCodecAdaptable { get }
    
    /// Converts value to `Data`
    /// - Parameters:
    ///     - value: Value of type `Any` to be converted into `Data`
    /// - Returns: An optional `Data` from the provided value
    func toData(value: Any) -> Data?
    
    /// Converts provided data into `Any`
    /// - Parameters:
    ///     - data: `Data` to convert to `Any`
    /// - Returns: An optional `Any` from the provided `Data`
    func fromData(_ data: Data) -> Any?
}

/// An adapter that takes a generic type `T` and attempts to convert value of that typo
/// a `Data` or convert `Data` to the type
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

/// A dynamic adapter provider that provides an adapter based on the provided dynamic type
final class DynamicAdapterProvider {
    // MARK: - Dependencies
    
    let coder: ScaleCoder
    weak var runtimeMetadataProvider: RuntimeMetadataProvider?
    
    init(coder: ScaleCoder, runtimeMetadataProvider: RuntimeMetadataProvider) {
        self.coder = coder
        self.runtimeMetadataProvider = runtimeMetadataProvider
    }
    
    // MARK: -
    /// Provides an adapter based on the provided dynamic type
    /// - Parameters:
    ///     - type: Dynamic type based on which an adapter is provided
    /// - Returns: An adapter based on the provided dynamic type
    func adapterProvider(for type: DynamicType.Type) async throws -> AdapterProtocol {
        guard let typeDef: RuntimeTypeDef
                = try await runtimeMetadataProvider?.runtimeMetadata().lookup.findItemByIndex(type.lookupIndex)?.def else {
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
    
    /// Finds an adapter based on the provided runtime primitive;
    /// - Parameters:
    ///     - primitive: A runtime primitive based on which an adapter will be provided
    /// -  Returns: An adapter for the primitive
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
