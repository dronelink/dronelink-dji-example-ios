platform :ios, '12.0'
inhibit_all_warnings!
use_frameworks!

target 'DronelinkDJIExample' do
  pod 'DronelinkCore', '~> 1.1.1'
  pod 'DronelinkCoreUI', '~> 1.0.4'
  pod 'DronelinkDJI', '~> 1.1.1'
  pod 'DronelinkDJIUI', '~> 1.0.4'
  post_install do |installer|
    installer.pods_project.targets.each do |target|
      target.build_configurations.each do |config|
        config.build_settings['ENABLE_BITCODE'] = 'NO'
      end
    end
  end
end