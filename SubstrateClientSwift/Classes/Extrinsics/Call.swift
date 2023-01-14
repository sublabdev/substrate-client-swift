import Foundation

/// An extrinsic call
public class Call<T: Codable> {
    let moduleName: String
    let name: String
    let value: T
    
    init(moduleName: String, name: String, value: T) {
        self.moduleName = moduleName
        self.name = name
        self.value = value
    }
}
