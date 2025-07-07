Pod::Spec.new do |spec|
  spec.name         = "AkilesSDK"
  spec.version      = "1.0.0"
  spec.summary      = "Akiles iOS SDK"
  spec.description  = <<-DESC
                      Akiles iOS SDK provides functionality for iOS applications.
                      DESC

  spec.homepage     = "https://github.com/akiles/akiles-ios"
  spec.license      = { :type => "LicenseRef-Akiles-Proprietary", :file => "LICENSE" }
  spec.author       = { "Akiles Technologies S.L." => "support@akiles.app" }

  spec.platform     = :ios, "11.0"
  spec.source       = { :git => "https://github.com/akiles/akiles-ios.git", :tag => "#{spec.version}" }

  spec.vendored_frameworks = "AkilesSDK.xcframework"
  spec.preserve_paths = "AkilesSDK.xcframework"

  spec.requires_arc = true
  spec.swift_version = "5.0"

  spec.pod_target_xcconfig = {
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64'
  }
  spec.user_target_xcconfig = {
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64'
  }
end
