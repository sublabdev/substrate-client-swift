/**
 *
 * Copyright 2023 SUBSTRATE LABORATORY LLC <info@sublab.dev>
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0

 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 * 
 */

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
        
        // We read this as Any
        do {
            let readValue = try adapter.scaleAdapter.tryRead(from: reader)
            if let data = adapter.toData(value: readValue) {
                if let value = dynamicType.init(data: data) as? T {
                    return value
                } else {
                    // shouldn't happen in fact as T = DynamicType
                    throw DynamicAdapterError.internalFailure
                }
            } else if let value = readValue as? T {
                return value
            } else {
                throw DynamicAdapterError.internalFailure
            }
        } catch let error {
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
        
        var data = value.toData()
        if let bytesLength = adapter.bytesLength, data.count != bytesLength, bytesLength > data.count {
            // Prepend '0' bytes if not enough size to prevent Numeric.fromData failure
            let diff = bytesLength - data.count
            data = (0..<diff).map { _ in UInt8(0) }.toData() + data
        }
        
        if let value = adapter.fromData(data) {
            // for conversions like Index <> UInt32(64, whatever)
            return try adapter.scaleAdapter.tryWrite(value: value)
        } else {
            // this might throw typeMismatch, from func should be present for custom conversions
            return try adapter.scaleAdapter.tryWrite(value: value)
        }
    }
}
