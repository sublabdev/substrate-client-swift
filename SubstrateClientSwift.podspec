Pod::Spec.new do |s|
  s.name             = 'SubstrateClientSwift'
  s.version          = '1.0.0'
  s.summary          = 'Pure Swift client library for Substrate.'
  s.homepage         = 'https://github.com/sublabdev/SubstrateClientSwift'
  s.license          = { :type => 'Apache 2.0', :file => 'LICENSE' }
  s.author           = { 'Substrate Laboratory LLC' => 'info@sublab.dev' }
  s.source           = { :git => 'https://github.com/sublabdev/substrate-client-swift.git', :tag => s.version.to_s }
  s.ios.deployment_target = '13.0'
  s.osx.deployment_target = '10.15'
  s.source_files = 'Sources/SubstrateClientSwift/**/*'
  s.dependency 'CommonSwift', '1.0.0'
  s.dependency 'HashingSwift', '1.0.0'
  s.dependency 'EncryptingSwift', '1.0.0'
  s.dependency 'ScaleCodecSwift', '1.0.0'
  s.dependency 'BigInt', '5.0.0'
end
