import CommonSwift
import Foundation
import ScaleCodecSwift

/// An adapter that decodes data dynamically. A subclass of `ScaleCodecAdapter`
final class DynamicAdapter<T>: ScaleCodecAdapter<T> {
    // MARK: - DynamicAdapter
    
    private let provider: DynamicAdapterProvider
    init(provider: DynamicAdapterProvider) {
        self.provider = provider
        super.init()
    }
    
    // MARK: - ScaleCodecAdapter
    /// Decodes data dynamically to a specified generic type `T` using the provided `DataReader`
    /// - Parameters:
    ///     - type: Generic type `T` to which the data should be decoded
    ///     - reader: Reader used to decode data
    /// - Returns: A decoded data of a provided generic type `T`
    override func read(_ type: T.Type?, from reader: DataReader) throws -> T {
        guard let dynamicType = type as? DynamicType.Type else {
            throw DynamicAdapterError.dynamicAdapterGivenInvalidType
        }
        
        let adapter = try runBlocking {
            try await provider.adapterProvider(for: dynamicType)
        }
        
//        print("[dynamic][\(type)] adapter = \(adapter)")
        // We read this as Any
        do {
            let readValue = try adapter.scaleAdapter.tryRead(from: reader)
//            print("[dynamic][\(type)] read value = \(readValue)")
            if let data = adapter.toData(value: readValue) {
//                print("[dynamic][\(type)] converted to data = \(data)")
                if let value = dynamicType.init(data: data) as? T {
//                    print("[dynamic][\(type)] read from data = \(value)")
                    return value
                } else {
                    // shouldn't happen in fact as T = DynamicType
//                    print("[dynamic][\(type)] couldn't read from data")
                    throw DynamicAdapterError.internalFailure
                }
            } else if let value = readValue as? T {
//                print("[dynamic][\(type)] pass \(value)")
                return value
            } else {
//                print("[dynamic][\(type)] couldn't read dynamic type")
                throw DynamicAdapterError.internalFailure
            }
        } catch let error {
//            print("[dynamic][\(type)] caught error = \(error)")
            throw error
        }
    }
    
    /// Encodes provided value to `Data`
    /// - Parameters:
    ///     - value: Value to be encoded
    /// - Returns: An encoded `Data`
    override func write(value: T) throws -> Data {
        guard let value = value as? DynamicType else {
            throw DynamicAdapterError.dynamicAdapterGivenInvalidType
        }
        
        let adapter = try runBlocking {
            try await provider.adapterProvider(for: type(of: value))
        }
        
        if let value = adapter.fromData(value.toData()) {
            // for conversions like Index <> UInt32(64, whatever)
            return try adapter.scaleAdapter.tryWrite(value: value)
        } else {
            // this might throw typeMismatch, from func should be present for custom conversions
            return try adapter.scaleAdapter.tryWrite(value: value)
        }
    }
}
