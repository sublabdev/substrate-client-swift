import Foundation
import ScaleCodecSwift

final class DynamicAdapter<T>: ScaleCodecAdapter<T> {
    // MARK: - DynamicAdapter
    
    private let provider: DynamicAdapterProvider
    init(provider: DynamicAdapterProvider) {
        self.provider = provider
        super.init()
    }
    
    // MARK: - ScaleCodecAdapter
    
    override func read(_ type: T.Type, from reader: DataReader) throws -> T {
        guard let dynamicType = type as? DynamicType.Type else {
            throw DynamicAdapterError.dynamicAdapterGivenInvalidType
        }
        
        let adapter = try provider.adapterProvider(for: dynamicType)
        // We read this as Any
        let readValue = try adapter.scaleAdapter.tryRead(Any.self, from: reader)
        if let data = adapter.toData(value: readValue) {
            if let value = adapter.fromData(data) as? T {
                return value
            } else {
                throw DynamicAdapterError.internalFailure
            }
        } else if let value = readValue as? T {
            return value
        } else {
            throw DynamicAdapterError.internalFailure
        }
    }
    
    override func write(value: T) throws -> Data {
        guard let value = value as? DynamicType else {
            throw DynamicAdapterError.dynamicAdapterGivenInvalidType
        }
        
        let adapter = try provider.adapterProvider(for: type(of: value))
        if let value = adapter.fromData(value.toData()) {
            // for conversions like Index <> UInt32(64, whatever)
            return try adapter.scaleAdapter.tryWrite(value: value)
        } else {
            // this might throw typeMismatch, from func should be present for custom conversions
            return try adapter.scaleAdapter.tryWrite(value: value)
        }
    }
}
