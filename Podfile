platform :ios, '12.0'
inhibit_all_warnings!
use_frameworks!

target 'DronelinkDJIExample' do
  pod 'DronelinkDJIUI', '~> 1.3.0'
  post_install do |installer|
    installer.pods_project.targets.each do |target|
      target.build_configurations.each do |config|
        config.build_settings['ENABLE_BITCODE'] = 'NO'
      end
    end
  end
end