import Foundation

/// An adapter to handle read and write operations for Data
public class DataAdapter: ScaleCodecAdapter<Data> {
    let arrayAdapter: ArrayAdapter<UInt8>
    
    public init(coder: ScaleCoder) {
        arrayAdapter = .init(coder: coder)
    }
    
    public override func read(_ type: Data.Type, from reader: DataReader) throws -> Data {
        Data(try arrayAdapter.read([UInt8].self, from: reader))
    }
    
    public override func write(value: Data) throws -> Data {
        try arrayAdapter.write(value: value.map { $0 })
    }
}
