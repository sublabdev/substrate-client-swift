import Foundation
import CommonSwift

/// A wrapper over a type. The wrapper conforms to `Hashable` protocol, since it is used as a key when caching adapters
struct TypeWrapper: Hashable {
    let type: Any.Type
    
    func hash(into hasher: inout Hasher) {
        String(describing: type).hash(into: &hasher)
    }
    
    static func == (lhs: TypeWrapper, rhs: TypeWrapper) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
}

/// Scale codec adapter factory interface
public protocol ScaleCodecAdapterFactory {
    /// Makes an adapter for a generic type `T`
    /// - Returns: An adapter for a generic type `T`
    func make<T>() -> ScaleCodecAdapter<T>
}

/// Handles providing or creating of a `ScaleCodecAdapter` object
public struct AdapterProvider {
    let instance: (any ScaleCodecAdaptable)?
    let factory: ScaleCodecAdapterFactory?
    
    public init(instance: (any ScaleCodecAdaptable)? = nil, factory: ScaleCodecAdapterFactory? = nil) {
        self.instance = instance
        self.factory = factory
    }
    
    /// Creates or provides an existing (under it's `instance` property) adapter
    /// - Returns: An adapter either created or cached
    public func adapter<T>() -> ScaleCodecAdapter<T>? {
        (instance as? ScaleCodecAdapter<T>) ?? (factory?.make() as? ScaleCodecAdapter<T>) ?? nil
    }
}

/// An interface for a type that can be handled by `GenericAdapter`
protocol ScaleGenericCodable {
    /// An initializer of the type
    /// - Parameters:
    ///     - reader: DataReader with a data to encode/decode
    ///     - coder:
    init(from reader: DataReader, coder: ScaleCoder) throws
    /// Writes (encodes) a scale generic codable value via encoder
    /// - Parameters:
    ///     - coder: A coder that encodes the generic codable value
    /// - Returns: An encoded Data
    func write(coder: ScaleCoder) throws -> Data
}

/// Generic adapter used for custom types that do not have their own adapter
public final class DefaultGenericAdapter<T>: ScaleCodecAdapter<T> {
    private let coder: ScaleCoder
    
    public init(coder: ScaleCoder) {
        self.coder = coder
    }
    
    /// Reads (decodes) data to specified type
    /// - Parameters:
    ///     - type: The type to which should attempt to decode the data
    ///     - reader: DataReader which contains the data that needs to be decoded and handles reading it
    /// - Returns: Decoded value of the provided type
    public override func read(_ type: T.Type, from reader: DataReader) throws -> T {
       if let type = type as? ScaleGenericCodable.Type {
            if let value = try type.init(from: reader, coder: coder) as? T {
                return value
            } else {
                // Shouldn't happen
                assertionFailure()
            }
        }
        
        throw ScaleCodecAdapterProvider.Error.noAdapterFound
    }
    
    /// Writes (encodes) the value
    /// - Parameters:
    ///     - value: The value to encode
    /// - Returns: The encoded Data
    public override func write(value: T) throws -> Data {
        if let value = value as? ScaleGenericCodable {
            return try value.write(coder: coder)
        }
        
        throw ScaleCodecAdapterProvider.Error.noAdapterFound
    }
}

final class GenericAdapter<T>: ScaleCodecAdapter<T> {
    private let providers: [AdapterProvider]
    private let onMatch: (AdapterProvider) -> Void
    
    init(providers: [AdapterProvider], onMatch: @escaping (AdapterProvider) -> Void) {
        self.providers = providers
        self.onMatch = onMatch
        super.init()
    }
    
    override func read(_ type: T.Type, from reader: DataReader) throws -> T {
        for provider in providers {
            let offsetBeforeTry = reader.offset
            do {
                guard let adapter = provider.adapter() as? ScaleCodecAdapter<T> else { continue }
                let value = try adapter.read(type, from: reader)
                onMatch(provider)
                return value
            } catch {
                // Reset offset to position before failed reading
                reader.offset = offsetBeforeTry
            }
        }
        
        throw ScaleCodecAdapterProvider.Error.noAdapterFound
    }
    
    override func write(value: T) throws -> Data {
        for provider in providers {
            do {
                guard let adapter = provider.adapter() as? ScaleCodecAdapter<T> else { continue }
                let data = try adapter.write(value: value)
                onMatch(provider)
                return data
            } catch {
                // For debugging purpose
            }
        }
        
        throw ScaleCodecAdapterProvider.Error.noAdapterFound
    }
}

/// Adapter provider that provides adapters based on the specified types
open class ScaleCodecAdapterProvider {
    /// Error cases that might appear while attempting to provide an adapter for a specified type
    enum Error: Swift.Error {
        case noOptionalAdapterProvided
        case noGenericAdapterProvided
        case noAdapterFound
    }
    
    private var adapters: [TypeWrapper: AdapterProvider] = [:]
    private var genericAdapters: [AdapterProvider] = []
    
    private var matchCache: [TypeWrapper: AdapterProvider] = [:]
    
    lazy var coder = ScaleCoder(adapterProvider: self)
    
    public init() { }

    /// Provides an adapter for a specified type
    /// - Parameters:
    ///     - type: A generic type for which an adapter should be found
    /// - Returns: An adapter for a provided type
    public func adapter<T>(for type: T.Type) throws -> ScaleCodecAdapter<T> {
        if let adapter = (try adapterProvider(for: type)?.adapter()) as? ScaleCodecAdapter<T> {
            return adapter
        }
        
        return genericAdapter(for: type)
    }
    
    /// Provides a generic adapter for a specified custom (or not directlye supported) type
    /// - Parameters:
    ///     - type: A generic type for which an adapter should be found
    /// - Returns: A generic adapter for a provided custom (or not directly supported) type
    private func genericAdapter<T>(for type: T.Type) -> ScaleCodecAdapter<T> {
        GenericAdapter(providers: genericAdapters) { [weak self] provider in
            self?.matchCache[TypeWrapper(type: type)] = provider
        }
    }
    
    /// Provides an adapter provider for a specified type
    /// - Parameters:
    ///     - type: A generic type for which an adapter provider should be found
    /// - Returns: An adapter provider for a provided type
    private func adapterProvider<T>(for type: T.Type) throws -> AdapterProvider? {
        if let provider = matchCache[TypeWrapper(type: type)] {
            return provider
        }
        
        return adapters[TypeWrapper(type: type)]
    }
    
    /// Caches an adapter for a specified type
    /// - Parameters:
    ///     - adapter: An adapter to cache
    ///     - type: A type for which it needs to be cached
    public func setAdapter<T>(_ adapter: ScaleCodecAdapter<T>, for type: T.Type) {
        adapters[TypeWrapper(type: type)] = .init(instance: adapter)
    }
    
    // Caches an adapter using a factory for a specified type
    /// - Parameters:
    ///     - factory: A factory from which an adapter is created later
    ///     - type: A type for which it needs to be cached
    public func setAdapter<T>(_ factory: ScaleCodecAdapterFactory, for type: T.Type) {
        adapters[TypeWrapper(type: type)] = .init(factory: factory)
    }
    
    /// Caches a generic adapter
    /// - Parameters:
    ///     - factory: A factory from which an adapter is created later
    public func addGenericAdapter(_ factory: ScaleCodecAdapterFactory) {
        genericAdapters.append(.init(factory: factory))
    }
}

// MARK: - Private

private extension ScaleCodecAdapterProvider {
    var encoder: ScaleEncoder {
        coder.encoder
    }
    
    var decoder: ScaleDecoder {
        coder.decoder
    }
}

// MARK: - Default Adapter Provider
/// Default scale codec adapter provider which provides adapter for the main by default supported types. The adapters for those types are set during the provider's initialization, so no additional step is required for that.
/// Also, the coder for the provider can be accessed directly
final public class DefaultScaleCodecAdapterProvider: ScaleCodecAdapterProvider {
    override public init() {
        super.init()
        
        // Bool
        provideBool()
        provideOptionalBool()
        
        // Int
        provideInt8()
        provideInt16()
        provideInt32()
        provideInt()
        provideInt64()
        provideInt128()
        provideInt256()
        provideInt512()
        
        // UInt
        provideUInt8()
        provideUInt16()
        provideUInt32()
        provideUInt()
        provideUInt64()
        provideUInt128()
        provideUInt256()
        provideUInt512()
        
        // String
        provideString()
        
        // Generic
        provideGeneric()
        
        // Data
        provideData()
    }
    
    // Methods for setting adapters for specific types
    private func provideBool() {
        setAdapter(
            BoolAdapter(),
            for: Bool.self
        )
    }
    
    private func provideOptionalBool() {
        setAdapter(
            OptionalBoolAdapter(),
            for: Bool?.self
        )
    }
    
    private func provideInt8() {
        setAdapter(
            NumericAdapter<Int8>(),
            for: Int8.self
        )
    }
    
    private func provideInt16() {
        setAdapter(
            NumericAdapter<Int16>(),
            for: Int16.self
        )
    }
    
    private func provideInt32() {
        setAdapter(
            NumericAdapter<Int32>(),
            for: Int32.self
        )
    }
    
    private func provideInt() {
        setAdapter(
            NumericAdapter<Int>(),
            for: Int.self
        )
    }

    private func provideInt64() {
        setAdapter(
            NumericAdapter<Int64>(),
            for: Int64.self
        )
    }
    
    private func provideUInt8() {
        setAdapter(
            NumericAdapter<UInt8>(),
            for: UInt8.self
        )
    }
    
    private func provideUInt16() {
        setAdapter(
            NumericAdapter<UInt16>(),
            for: UInt16.self
        )
    }
    
    private func provideUInt32() {
        setAdapter(
            NumericAdapter<UInt32>(),
            for: UInt32.self
        )
    }
    
    private func provideUInt() {
        setAdapter(
            NumericAdapter<UInt>(),
            for: UInt.self
        )
    }
    
    private func provideUInt64() {
        setAdapter(
            NumericAdapter<UInt64>(),
            for: UInt64.self
        )
    }
    
    private func provideInt128() {
        setAdapter(
            Int128Adapter(),
            for: Int128.self
        )
    }
    
    private func provideUInt128() {
        setAdapter(
            UInt128Adapter(),
            for: UInt128.self
        )
    }
    
    private func provideInt256() {
        setAdapter(
            Int256Adapter(),
            for: Int256.self
        )
    }
    
    private func provideUInt256() {
        setAdapter(
            UInt256Adapter(),
            for: UInt256.self
        )
    }
    
    private func provideInt512() {
        setAdapter(
            Int512Adapter(),
            for: Int512.self
        )
    }
    
    private func provideUInt512() {
        setAdapter(
            UInt512Adapter(),
            for: UInt512.self
        )
    }
    
    private func provideString() {
        setAdapter(
            StringAdapter(coder: coder),
            for: String.self
        )
    }
    
    private func provideData() {
        setAdapter(
            DataAdapter(coder: coder),
            for: Data.self
        )
    }
    
    private func provideGeneric() {
        addGenericAdapter(DefaultGenericAdapterProviderFactory(coder: coder))
    }
}

// MARK: - GenericAdapterProviderFactory
/// An adapter provider factory for a generic type
struct DefaultGenericAdapterProviderFactory: ScaleCodecAdapterFactory {
    private let coder: ScaleCoder
    
    init(coder: ScaleCoder) {
        self.coder = coder
    }
    
    /// Makes a generic adapter for a generic type `T`
    /// - Returns: A generic adapter for a generic type `T`
    func make<T>() -> ScaleCodecAdapter<T> {
        DefaultGenericAdapter<T>(coder: coder)
    }
}
