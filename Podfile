platform :ios, '12.0'
inhibit_all_warnings!
use_frameworks!

target 'DronelinkDJIExample' do
  pod 'DronelinkCore', '~> 2.6.0'
  pod 'DronelinkCoreUI', '~> 2.6.0'
  pod 'DronelinkDJI', '~> 2.6.0'
  pod 'DronelinkDJIUI', '~> 2.6.0'
  post_install do |installer|
    installer.pods_project.targets.each do |target|
      target.build_configurations.each do |config|
        config.build_settings['ENABLE_BITCODE'] = 'NO'
      end
    end
  end
end