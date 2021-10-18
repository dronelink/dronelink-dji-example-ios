platform :ios, '12.0'
inhibit_all_warnings!
use_frameworks!

target 'DronelinkDJIExample' do
  pod 'DronelinkCore', '~> 3.0.0'
  pod 'DronelinkDJI', :git => 'https://github.com/dronelink/dronelink-dji-ios.git', :tag => '3.0.0'
  pod 'DronelinkCoreUI', :git => 'https://github.com/dronelink/dronelink-core-ui-ios.git', :tag => '3.0.0'
  pod 'DronelinkDJIUI', :git => 'https://github.com/dronelink/dronelink-dji-ui-ios.git', :tag => '3.0.0'
  post_install do |installer|
    installer.pods_project.targets.each do |target|
      target.build_configurations.each do |config|
        config.build_settings['ENABLE_BITCODE'] = 'NO'
      end
    end
  end
end