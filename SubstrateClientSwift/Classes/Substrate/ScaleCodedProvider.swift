import Foundation
import ScaleCodecSwift

extension ScaleCoder {
    func provideDynamicAdapter(runtimeMetadataProvider: RuntimeMetadataProvider) {
        adapterProvider.addGenericAdapter(
            DynamicAdapterFactory(coder: self, runtimeMetadataProvider: runtimeMetadataProvider)
        )
    }
}

private final class DynamicAdapterFactory: ScaleCodecAdapterFactory {
    private let coder: ScaleCoder
    private let runtimeMetadataProvider: RuntimeMetadataProvider
    
    init(coder: ScaleCoder, runtimeMetadataProvider: RuntimeMetadataProvider) {
        self.coder = coder
        self.runtimeMetadataProvider = runtimeMetadataProvider
    }
    
    func make<T>() -> ScaleCodecAdapter<T> {
        DynamicAdapter(provider: .init(coder: coder, runtimeMetadataProvider: runtimeMetadataProvider))
    }
}
