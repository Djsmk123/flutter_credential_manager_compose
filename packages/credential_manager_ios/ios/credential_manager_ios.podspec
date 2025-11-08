Pod::Spec.new do |s|
  s.name             = 'credential_manager_ios'
  s.version          = '2.0.4'
  s.summary          = 'iOS implementation of the credential_manager plugin using Keychain and Autofill.'
  s.description      = <<-DESC
                       iOS implementation of the credential_manager plugin. This package provides iOS-specific implementation using Keychain and Autofill for secure credential storage.
                       DESC
  s.homepage         = 'https://github.com/Djsmk123/flutter_credential_manager_compose'
  s.license          = { :type => 'MIT' }
  s.author           = { 'Djsmk123' => 'djsmk123@example.com' }
  s.source           = { :git => 'https://github.com/Djsmk123/flutter_credential_manager_compose.git', :tag => s.version.to_s }
  s.ios.deployment_target = '12.0'
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '12.0'
  s.swift_version = '5.0'
end
