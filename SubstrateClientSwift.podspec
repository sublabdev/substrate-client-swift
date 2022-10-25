Pod::Spec.new do |s|
  s.name             = 'SubstrateClientSwift'
  s.version          = '1.0.0'
  s.summary          = 'Pure Swift client library for Substrate.'

#  s.description      = <<-DESC
#TODO: Add long description of the pod here.
#                       DESC

  s.homepage         = 'https://github.com/sublabdev/SubstrateClientSwift'
  s.license          = { :type => 'Apache 2.0', :file => 'LICENSE' }
  s.author           = { 'Tigran Iskandaryan' => 'tiger@sublab.dev' }
  s.source           = { :git => 'https://github.com/sublabdev/SubstrateClientSwift.git', :tag => s.version.to_s }
  s.ios.deployment_target = '13.0'
  s.source_files = 'SubstrateClientSwift/Classes/**/*'
  s.dependency 'BigInt'
  
end
