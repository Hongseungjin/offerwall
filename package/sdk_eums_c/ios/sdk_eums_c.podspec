#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint sdk_eums_c.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'sdk_eums_c'
  s.version          = '0.0.1'
  s.summary          = 'A new Flutter plugin project.'
  s.description      = <<-DESC
A new Flutter plugin project.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h', 'libs/Adsync2/inlcude/adsync2.h'
  s.dependency 'Flutter'
  s.platform = :ios, '11.0'
  s.dependency 'AdPopcornOfferwall', '~> 4.3.4'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386, arm64' }

  s.static_framework = true
  # # s.swift_version = '5.0' 
  # s.preserve_paths = 'libs/AdPopcornOfferwall.framework', 'libs/AdPopcornOfferwall.bundle'
  # s.vendored_frameworks = 'libs/AdPopcornOfferwall.framework'
  # s.resource = 'libs/AdPopcornOfferwall.bundle'

  # s.xcconfig = { 'OTHER_LDFLAGS' => '-framework AdPopcornOfferwall' }



  s.ios.vendored_library = 'libs/Adsync2/libadsync2.a', 'libs/sdk/libNASWall_20220215.a'
  s.vendored_libraries = 'libs/Adsync2/libadsync2.a', 'libs/sdk/libNASWall_20220215.a'
  s.source_files        = 'Classes/**/*', "libs/Adsync2/inlcude/*.h", "libs/sdk/*.h"
  
end
