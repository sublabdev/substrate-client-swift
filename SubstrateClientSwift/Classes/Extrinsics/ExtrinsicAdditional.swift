import Foundation

class ExtrinsicAdditional {
    let specVersion: UInt32
    let txVersion: UInt32
    let genesisHash: Data
    let mortalityCheckpoint: Data
    let marker: Any
    
    init(
        specVersion: UInt32,
        txVersion: UInt32,
        genesisHash: Data,
        mortalityCheckpoint: Data,
        marker: Any
    ) {
        self.specVersion = specVersion
        self.txVersion = txVersion
        self.genesisHash = genesisHash
        self.mortalityCheckpoint = mortalityCheckpoint
        self.marker = marker
    }
}
