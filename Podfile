source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '10.0'
inhibit_all_warnings!

target 'YourCoast' do
    pod 'GoogleAnalytics'
    pod 'SDWebImage', '~> 4.0'
    pod 'GTMNSStringHTMLAdditions'
    pod 'QBImagePickerController'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      if config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'].to_f < 10.0
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '10.0'
      end
    end
  end

  installer.pods_project.build_configurations.each do |config|
      config.build_settings['ENABLE_TESTABILITY'] = 'YES'
      config.build_settings['ONLY_ACTIVE_ARCH'] = 'YES'
  end
end
