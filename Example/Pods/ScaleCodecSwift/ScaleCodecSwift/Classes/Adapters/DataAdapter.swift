import Foundation

class DataAdapter: ScaleCodecAdapter<Data> {
    let arrayAdapter: ArrayAdapter<UInt8>
    
    init(coder: ScaleCoder) {
        arrayAdapter = .init(coder: coder)
    }
    
    override func read(_ type: Data.Type, from reader: DataReader) throws -> Data {
        Data(try arrayAdapter.read([UInt8].self, from: reader))
    }
    
    
    override func write(value: Data) throws -> Data {
        try arrayAdapter.write(value: value.map { $0 })
    }
}
