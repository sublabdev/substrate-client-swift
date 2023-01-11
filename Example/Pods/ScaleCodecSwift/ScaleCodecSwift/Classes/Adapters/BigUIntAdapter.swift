import Foundation
import BigInt
import CommonSwift

fileprivate enum BigUIntCompressingError: Swift.Error {
    case tooBigValue
    case noCompressedData
}

/// Adapter for BigUInt
public final class BigUIntAdapter: ScaleCodecAdapter<BigUInt> {
    private let coder: ScaleCoder
    
    public init(coder: ScaleCoder) {
        self.coder = coder
    }

    public override func read(_ type: BigUInt.Type, from reader: DataReader) throws -> BigUInt {
        let first = try coder.decoder.decode(UInt8.self, from: reader)
        let mode = first & 0b11
        let value = first | 0b11
        
        switch mode {
        case 0b00:
            return BigUInt(UInt8(value) >> 2)
        case 0b01:
            return BigUInt(try readRest(of: UInt16.self, value: value, dataReader: reader))
        case 0b10:
            return BigUInt(try readRest(of: UInt32.self, value: value, dataReader: reader))
        default:
            let count = value >> 2 + 4
            let data = Data(try (0..<count).map { _ in try coder.decoder.decode(UInt8.self, from: reader) })
            return try BigUInt(compressedData: data)
        }
    }

    public override func write(value: BigUInt) throws -> Data {
        switch value {
        case (0..<1 << (UInt8.bitWidth - 2)): return try coder.encoder.encode((UInt8(value) << 2))
        case (0..<1 << (UInt16.bitWidth - 2)): return try coder.encoder.encode((UInt16(value) << 2 | 0b01))
        case (0..<1 << (UInt32.bitWidth - 2)): return try coder.encoder.encode((UInt32(value) << 2 | 0b10))
        default:
            let data = value.compressData()
            let count = UInt8(data.count - 4) << 2 | 0b11
            return Data([count]) + data
        }
    }
    
    private func readRest<T: FixedWidthInteger>(
        of type: T.Type,
        value: UInt8,
        dataReader: DataReader
    ) throws -> BigUInt where T: Codable {
        let bytesLeft = UInt8(type.bitWidth / UInt8.bitWidth) - 1
        let data = Data([value] + (try (0..<bytesLeft).map { _ in try coder.decoder.decode(UInt8.self, from: dataReader) }))
        return BigUInt(try NumericAdapter<T>().read(type, from: DataReader(data: data))) >> 2
    }
}

// Since in 'BigUInt' library we have a custom conformance to Codable which is not conforming to ScaleCodec principles
// We need to override it with an extension conforming to ScaleGenericCodable, as we prioritize it over the default Codable implementations
extension BigUInt: ScaleGenericCodable {
    init(from reader: DataReader, coder: ScaleCoder) throws {
        self = try BigUIntAdapter(coder: coder).read(BigUInt.self, from: reader)
    }
    
    func write(coder: ScaleCoder) throws -> Data {
        try BigUIntAdapter(coder: coder).write(value: self)
    }
}


// MARK: BigUInt Extension
private extension BigUInt {
    // Initializes BigUInt from a compressed data by adding the missing zeroes at the end
    init(compressedData: Data) throws {
        self.init()
        
        switch compressedData.count {
        case (0...UInt8.byteWidth): self = BigUInt(UInt8(littleEndian: compressedData.fillingZeroesAtEnd(byteWidth: UInt8.byteWidth).withUnsafeBytes { $0.load(as: UInt8.self) }))
        case (0...UInt16.byteWidth): self = BigUInt(UInt16(littleEndian: compressedData.fillingZeroesAtEnd(byteWidth: UInt16.byteWidth).withUnsafeBytes { $0.load(as: UInt16.self) }))
        case (0...UInt32.byteWidth): self = BigUInt(UInt32(littleEndian: compressedData.fillingZeroesAtEnd(byteWidth: UInt32.byteWidth).withUnsafeBytes { $0.load(as: UInt32.self) }))
        case (0...UInt64.byteWidth): self = BigUInt(UInt64(littleEndian: compressedData.fillingZeroesAtEnd(byteWidth: UInt64.byteWidth).withUnsafeBytes { $0.load(as: UInt64.self) }))
        default:
            var dataCount = compressedData.count
            if dataCount % UInt64.byteWidth != 0 {
                dataCount = Int(ceil((Double(dataCount) / Double(UInt64.byteWidth)))) * UInt64.byteWidth
            }
         
            let data = compressedData.fillingZeroesAtEnd(byteWidth: dataCount)
            self = BigUInt(Data(data.reversed()))
        }
    }
    
    /// Compresses `BigUInt`
    /// - Returns: A `Data` from `BigUInt` without zeroes at the end
    func compressData() -> Data {
        Data(serialize().reversed()).removingZeroesAtEnd
    }
}

// MARK: - FixedWidthInteger Extension
private extension FixedWidthInteger {
    static var byteWidth: Int { bitWidth / 8 }
}
