import Foundation

struct TypeWrapper: Hashable {
    let type: Any.Type
    
    func hash(into hasher: inout Hasher) {
        String(describing: type).hash(into: &hasher)
    }
    
    static func == (lhs: TypeWrapper, rhs: TypeWrapper) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
}

protocol ScaleCodecAdapterFactory {
    func make<T>() -> ScaleCodecAdapter<T>
}

struct AdapterProvider {
    let instance: (any ScaleCodecAdaptable)?
    let factory: ScaleCodecAdapterFactory?
    
    init(instance: (any ScaleCodecAdaptable)? = nil, factory: ScaleCodecAdapterFactory? = nil) {
        self.instance = instance
        self.factory = factory
    }
    
    func adapter<T>() -> ScaleCodecAdapter<T>? {
        (instance as? ScaleCodecAdapter<T>) ?? (factory?.make() as? ScaleCodecAdapter<T>) ?? nil
    }
}

protocol ScaleGenericCodable {
    init(from reader: DataReader, coder: ScaleCoder) throws
    func write(coder: ScaleCoder) throws -> Data
}

final class GenericAdapter<T>: ScaleCodecAdapter<T> {
    
    private let coder: ScaleCoder
    
    init(coder: ScaleCoder) {
        self.coder = coder
    }
    
    override func read(_ type: T.Type, from reader: DataReader) throws -> T {
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
    
    override func write(value: T) throws -> Data {
        if let value = value as? ScaleGenericCodable {
            return try value.write(coder: coder)
        }
        
        throw ScaleCodecAdapterProvider.Error.noAdapterFound
    }
}

open class ScaleCodecAdapterProvider {
    enum Error: Swift.Error {
        case noOptionalAdapterProvided
        case noGenericAdapterProvided
        case noAdapterFound
    }
    
    private var adapters: [TypeWrapper: AdapterProvider] = [:]
    private var _genericAdapter: AdapterProvider? = nil
    
    private var matchCache: [TypeWrapper: AdapterProvider] = [:]
    
    lazy var coder = ScaleCoder(
        encoder: ScaleEncoder(adapterProvider: self),
        decoder: ScaleDecoder(adapterProvider: self)
    )
    
    public init() { }

    func adapter<T>(for type: T.Type) throws -> ScaleCodecAdapter<T> {
        if let adapter = (try adapterProvider(for: type)?.adapter()) as? ScaleCodecAdapter<T> {
            return adapter
        }
        
        return try genericAdapter()
    }
    
    func genericAdapter<T>() throws -> ScaleCodecAdapter<T> {
        guard let adapter = _genericAdapter?.adapter() as? ScaleCodecAdapter<T> else {
            throw Error.noGenericAdapterProvided
        }
        
        return adapter
    }
    
    private func adapterProvider<T>(for type: T.Type) throws -> AdapterProvider? {
        if let provider = matchCache[TypeWrapper(type: type)] {
            return provider
        }
        
        return adapters[TypeWrapper(type: type)]
    }
    
    func setAdapter<T>(_ adapter: ScaleCodecAdapter<T>, for type: T.Type) {
        adapters[TypeWrapper(type: type)] = .init(instance: adapter)
    }
    
    func setAdapter<T>(_ factory: ScaleCodecAdapterFactory, for type: T.Type) {
        adapters[TypeWrapper(type: type)] = .init(factory: factory)
    }
    
    func setGenericAdapter(_ factory: ScaleCodecAdapterFactory) {
        _genericAdapter = .init(factory: factory)
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
        
        // UInt
        provideUInt8()
        provideUInt16()
        provideUInt32()
        provideUInt()
        provideUInt64()
        
        // String
        provideString()
        
        // Generic
        provideGeneric()
        
        // Data
        provideData()
    }
    
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
        setGenericAdapter(GenericAdapterProviderFactory(coder: coder))
    }
}

// MARK: - GenericAdapterProviderFactory

struct GenericAdapterProviderFactory: ScaleCodecAdapterFactory {
    private let coder: ScaleCoder
    
    init(coder: ScaleCoder) {
        self.coder = coder
    }
    
    func make<T>() -> ScaleCodecAdapter<T> {
        GenericAdapter<T>(coder: coder)
    }
}
