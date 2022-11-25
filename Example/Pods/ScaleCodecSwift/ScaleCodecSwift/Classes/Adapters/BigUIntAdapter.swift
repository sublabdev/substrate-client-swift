import Foundation
import BigInt

fileprivate enum BigUIntCompressingError: Swift.Error {
    case tooBigValue
    case noCompressedData
}

final class BigUIntAdapter: ScaleCodecAdapter<BigUInt> {
    private let coder: ScaleCoder
    
    init(coder: ScaleCoder) {
        self.coder = coder
    }

    override func read(_ type: BigUInt.Type, from reader: DataReader) throws -> BigUInt {
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

    override func write(value: BigUInt) throws -> Data {
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
    // TODO: Check whether it's in BigEndian or LittleEndian? If Big then should be converted to LittleEndian. Get words and reverse it
    //
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
            
            // UInt256: [UInt64, UInt64, UInt64, UInt64]
            // UInt256.byteWidth = UInt64 * 4 == 8 * 4 = 32
            // dataCount == 29
            // dataCount = Int(ceil(29 / 8)) * 8 == 32
            
            let data = compressedData.fillingZeroesAtEnd(byteWidth: dataCount)
            self = BigUInt(Data(data.reversed()))
//            let dataReader = DataReader(data: compressedData.fillingZeroesAtEnd(byteWidth: bitWidth / 8))
//            let numericAdapter = NumericAdapter<UInt64>()
//
//            let bits = try (0..<4).map { _ in try numericAdapter.read(UInt64.self, from: dataReader) }.map { UInt($0) }
//            self = BigUInt(words: bits)
        }
    }
    
    func compressData() -> Data {
        Data(serialize().reversed()).removingZeroesAtEnd
//        var data: Data
//        let littleEndianData = Data(serialize().reversed()).removingZeroesAtEnd
//
//        switch self {
//        case (0..<1 << UInt8.bitWidth): data = withUnsafeBytes(of: UInt8(self), { Data($0) })
//        case (0..<1 << UInt16.bitWidth): data = withUnsafeBytes(of: UInt16(self), { Data($0) })
//        case (0..<1 << UInt32.bitWidth): data = withUnsafeBytes(of: UInt32(self), { Data($0) })
//        case (0..<1 << UInt64.bitWidth): data = withUnsafeBytes(of: UInt64(self), { Data($0) })
//        default:
//            data = littleEndianData
//            let serializedData = serialize().reversed()
//            let headerValue = ((serializedData.count - 4) << 2) | 0b11
//
//            guard headerValue < 256 else {
//                throw BigUIntCompressingError.tooBigValue
//            }
//
//            data = Data(repeating: UInt8(headerValue), count: 1) + Data(serializedData)
//        }
        
//        return data.removingZeroesAtEnd
    }
}

// MARK: - FixedWidthInteger Extension

private extension FixedWidthInteger {
    static var byteWidth: Int { bitWidth / 8 }
}

// MARK: - Data Extension

private extension Data {
    var removingZeroesAtEnd: Data {
        guard let offset = lastIndex(where: { $0 > 0 }) else {
            return Data([0])
        }
    
        return self[0...offset]
    }
    
    func fillingZeroesAtEnd(byteWidth: Int) -> Data {
        guard count != byteWidth else { return self }
        
        var data = self
        for _ in 0..<(byteWidth - count) {
            data.append(0)
        }
        
        return data
    }
}
