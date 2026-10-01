# Uncomment the next line to define a global platform for your project
platform :ios, '26.0'

target 'LuckyX' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for LuckyX
  pod 'RealmSwift', '~> 20.0'
  pod 'lottie-ios', '2.5.2'
  pod 'Popover', '1.2.0'

  target 'LuckyXTests' do
    inherit! :search_paths
  end

end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '26.0'
    end
  end
end
