Pod::Spec.new do |s|
  s.name             = 'TapFramework'
  s.version          = '2.0'
  s.summary          = 'Tap is a framework to build tappable iOS Apps'
  s.description      = <<-DESC
    Tap is a framework to build tappable iOS Apps
    DESC

  s.homepage         = 'https://github.com/clickntap/tap_framework_ios'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Tonino Mendicino' => 'tonino@clickntap.com' }
  s.source           = { :git => 'https://github.com/clickntap/tap_framework_ios.git', :tag => s.version.to_s }
  s.ios.deployment_target = '10.0'
  s.source_files = 'tap_framework_ios/Classes/**/*'
  s.resource_bundles = {
    'tap_framework_ios' => ['tap_framework_ios/Assets/*.m4a','tap_framework_ios/Assets/*.ttf']
  }
  s.dependency 'AFNetworking'
  s.dependency 'UIColor-Utilities'
  s.dependency 'MMMaterialDesignSpinner'
  s.dependency 'ZipArchive'
end
