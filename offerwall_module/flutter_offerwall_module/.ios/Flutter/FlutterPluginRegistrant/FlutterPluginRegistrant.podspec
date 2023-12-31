#
# Generated file, do not edit.
#

Pod::Spec.new do |s|
  s.name             = 'FlutterPluginRegistrant'
  s.version          = '0.0.1'
  s.summary          = 'Registers plugins with your Flutter app'
  s.description      = <<-DESC
Depends on all your plugins, and provides a function to register them.
                       DESC
  s.homepage         = 'https://flutter.dev'
  s.license          = { :type => 'BSD' }
  s.author           = { 'Flutter Dev Team' => 'flutter-dev@googlegroups.com' }
  s.ios.deployment_target = '11.0'
  s.source_files =  "Classes", "Classes/**/*.{h,m}"
  s.source           = { :path => '.' }
  s.public_header_files = './Classes/**/*.h'
  s.static_framework    = true
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
  s.dependency 'Flutter'
  s.dependency 'app_settings'
  s.dependency 'audio_session'
  s.dependency 'device_info_plus'
  s.dependency 'devicelocale'
  s.dependency 'eums'
  s.dependency 'firebase_core'
  s.dependency 'firebase_crashlytics'
  s.dependency 'firebase_messaging'
  s.dependency 'flutter_background_service_ios'
  s.dependency 'flutter_component'
  s.dependency 'flutter_inappwebview'
  s.dependency 'flutter_local_notifications'
  s.dependency 'flutter_overlay_window'
  s.dependency 'geolocator_apple'
  s.dependency 'image_picker_ios'
  s.dependency 'just_audio'
  s.dependency 'package_info_plus'
  s.dependency 'path_provider_foundation'
  s.dependency 'permission_handler_apple'
  s.dependency 'shared_preferences_foundation'
  s.dependency 'sqflite'
  s.dependency 'url_launcher_ios'
  s.dependency 'video_player_avfoundation'
  s.dependency 'wakelock'
  s.dependency 'webview_flutter_wkwebview'
end
