target 'FamilyAssets' do
    pod 'SnapKit', '~> 4.0.0'
    pod 'IQKeyboardManagerSwift'
end

post_install do |installer|
  installer.pods_project.build_configurations.each do |config|
    config.build_settings.delete('CODE_SIGNING_ALLOWED')
    config.build_settings.delete('CODE_SIGNING_REQUIRED')
  end
end
