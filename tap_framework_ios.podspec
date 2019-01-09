Pod::Spec.new do |s|
  s.name             = 'tap_framework_ios'
  s.version          = '2.0.1'
  s.summary          = 'Tap is a framework to build tappable iOS Apps'
  s.description      = <<-DESC
    Tappable Apps always needs Clickable Platforms :)
    DESC
  s.homepage         = 'https://github.com/clickntap/tap_framework_ios'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Tonino Mendicino' => 'tonino@clickntap.com' }
  s.source           = { :git => 'https://github.com/clickntap/tap_framework_ios.git', :tag => s.version.to_s }
  s.ios.deployment_target = '10.0'
  s.source_files = 'Classes/**/*'
  s.resource_bundles = {
    'tap_framework_ios' => ['Assets/*.m4a','Assets/*.ttf']
  }
  s.dependency 'AFNetworking'
  s.dependency 'UIColor-Utilities'
  s.dependency 'MMMaterialDesignSpinner'
  s.dependency 'ZipArchive'
end
