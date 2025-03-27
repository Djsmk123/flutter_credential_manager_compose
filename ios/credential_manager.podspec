Pod::Spec.new do |s|
  s.name             = 'credential_manager'
  s.version          = '1.0.4'
  s.summary          = 'Credential Manager plugin, helps with one-tap Login functionality and stores credentials in Google service account of user.'
  s.description      = <<-DESC
                       Credential Manager plugin for Flutter, providing one-tap login functionality and secure credential storage in the user's Google service account.
                       DESC
  s.homepage         = 'https://github.com/Djsmk123/flutter_credential_manager_compose'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Djsmk123' => 'djsmk123@example.com' }
  s.source           = { :git => 'https://github.com/Djsmk123/flutter_credential_manager_compose.git', :tag => s.version.to_s }
  s.ios.deployment_target = '10.0'
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '10.0'
  s.swift_version = '5.7'
end
