import Foundation

enum Endpoint: CaseIterable {
    case kusama
    case polkadot
    case westend
    
    private var bundle: Bundle {
        Bundle(for: TestRuntimeMetadata.self)
    }
    
    var endpointInfo: EndpointInfo {
        switch self {
        case .kusama:
            return .init(
                url: Constants.kusamaUrl,
                localURL: bundle.url(forResource: "kusama-metadata", withExtension: ""),
                magicNumber: 1635018093
            )
            
        case .polkadot:
            return .init(
                url: Constants.polkadotUrl,
                localURL: bundle.url(forResource: "polkadot-metadata", withExtension: ""),
                magicNumber: 1635018093
            )
           
        case .westend:
            return .init(
                url: Constants.westendUrl,
                localURL: bundle.url(forResource: "westend-metadata", withExtension: ""),
                magicNumber: 1635018093
            )
        }
    }
}
