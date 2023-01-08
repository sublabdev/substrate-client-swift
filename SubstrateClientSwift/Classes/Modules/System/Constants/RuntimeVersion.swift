import Foundation

/// Runtime version
public class RuntimeVersion : Codable {
    let specName: String
    let implName: String
    let authoringVersion: Int
    let specVersion: Int
    let implVersion: Int
    let apis: [RuntimeVersionApi]
    let txVersion: Int
    let stateVersion: UInt8
    
    init(
        specName: String,
        implName: String,
        authoringVersion: Int,
        specVersion: Int,
        implVersion: Int,
        apis: [RuntimeVersionApi],
        txVersion: Int,
        stateVersion: UInt8
    ) {
        self.specName = specName
        self.implName = implName
        self.authoringVersion = authoringVersion
        self.specVersion = specVersion
        self.implVersion = implVersion
        self.apis = apis
        self.txVersion = txVersion
        self.stateVersion = stateVersion
    }
}

public class RuntimeVersionApi: Codable {
    let index: Int
    
    init(index: Int) {
        self.index = index
    }
}
