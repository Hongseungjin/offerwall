#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint sdk_eums.podspec` to validate before publishing.
#


pubspec = YAML.load_file(File.join('..', 'pubspec.yaml'))
library_version = pubspec['version'].gsub('+', '-')
Pod::Spec.new do |s|
  s.name             = 'sdk_eums'
  s.version          = library_version
  s.summary          = 'A new Flutter plugin project.'
  s.description      = <<-DESC
A new Flutter plugin project.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'
  s.platform = :ios, '9.0'
  s.static_framework = true
  s.swift_version = '5.0'


  

  s.pod_target_xcconfig = { 'OTHER_LDFLAGS' => '-framework TnkRwdSdk -framework adlibrary -framework IveOfferwallFramework -framework OhcCharge', 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386, arm64' }
  s.preserve_paths = 'libs/TnkRwdSdk.xcframework', 'libs/adlibrary.framework', 'libs/IveOfferwallFramework.framework', 'libs/OhcCharge.framework'
  s.vendored_frameworks = 'libs/TnkRwdSdk.xcframework', 'libs/adlibrary.framework', 'libs/IveOfferwallFramework.framework', 'libs/OhcCharge.framework'
end
