#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint deeplink_sdk.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'deeplink_sdk'
  s.version          = '1.0.0'
  s.summary          = 'A comprehensive Flutter SDK for handling deep links on iOS.'
  s.description      = <<-DESC
A comprehensive Flutter SDK for handling deep links on iOS with support for URL schemes and Universal Links.
                       DESC
  s.homepage         = 'https://github.com/yourusername/deeplink_sdk'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '11.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
