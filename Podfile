# Uncomment the next line to define a global platform for your project
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '14.0'

post_install do |installer|
    installer.generated_projects.each do |project|
        project.targets.each do |target|
            target.build_configurations.each do |config|
                config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
            
            # Xcode 15
            xcconfig_path = config.base_configuration_reference.real_path
                xcconfig = File.read(xcconfig_path)
                xcconfig_mod = xcconfig.gsub(/DT_TOOLCHAIN_DIR/, "TOOLCHAIN_DIR")
                File.open(xcconfig_path, "w") { |file| file << xcconfig_mod }
            end
        end
    end
end

target 'CookAndShare' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for CookAndShare
  pod 'FirebaseAuth'
  pod 'FirebaseFirestore'
  pod 'FirebaseFirestoreSwift'
  pod 'FirebaseStorage'
  pod 'SwiftLint'
  pod 'GoogleMaps'
  pod 'GooglePlaces'
  pod 'IQKeyboardManager'
  pod 'FirebaseMessaging'
  pod 'Kingfisher'
  pod 'lottie-ios'
  pod 'SPAlert'
  pod 'Hero'
  pod 'ESPullToRefresh'
  pod 'KeychainSwift'
  pod 'SwiftJWT'
  pod 'FirebaseCrashlytics'
  pod 'Alamofire'
end
