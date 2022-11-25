import Foundation

class StringAdapter: ScaleCodecAdapter<String> {
    enum Error: Swift.Error {
        case readError(Data)
        case writeError(String)
    }
    
    let dataAdapter: DataAdapter
    
    init(coder: ScaleCoder) {
        dataAdapter = .init(coder: coder)
    }
    
    override func read(_ type: String.Type, from reader: DataReader) throws -> String {
        let data = try dataAdapter.read(Data.self, from: reader)
        
        guard let result = String(data: .init(data), encoding: .utf8) else {
            throw Error.readError(.init(data))
        }
        
        return result
    }
    
    override func write(value: String) throws -> Data {
        guard let data = value.data(using: .utf8) else {
            throw Error.writeError(value)
        }
        
        return try dataAdapter.write(value: data)
    }
}
