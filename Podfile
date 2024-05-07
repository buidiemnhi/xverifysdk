# Uncomment the next line to define a global platform for your project
platform :ios, '13.0'
workspace 'xverifysdk.xcworkspace'
def sdk_dependencies
  pod 'CocoaLumberjack/Swift'
  pod 'ObjectMapper'
  pod 'SwiftDate'
  pod 'PINCache'
  pod 'SwiftyJSON'
  pod 'GoogleMLKit/Vision'
  pod 'GoogleMLKit/FaceDetection'
  pod 'GoogleMLKit/TextRecognition'
end

def common_dependencies
  pod 'Alamofire', '~> 5.8.1'
  pod 'OpenSSL-Universal', '~> 1.1.2200'
end
target 'xverifysdk' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for xverifysdk

  target 'xverifysdkTests' do
	project 'xverifysdk.xcodeproj'
  	common_dependencies
  	sdk_dependencies
    # Pods for testing
  end

end


post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['LD_NO_PIE'] = 'NO'
            config.build_settings['GCC_WARN_INHIBIT_ALL_WARNINGS'] = 'YES'
            config.build_settings['SWIFT_SUPPRESS_WARNINGS'] = 'YES'
            config.build_settings['APPLICATION_EXTENSION_API_ONLY'] = 'NO'
            config.build_settings['ENABLE_BITCODE'] = 'NO'
            config.build_settings['CODE_SIGNING_ALLOWED'] = 'NO'
            config.build_settings.delete 'IPHONEOS_DEPLOYMENT_TARGET'
            xcconfig_path = config.base_configuration_reference.real_path
            xcconfig = File.read(xcconfig_path)
            xcconfig_mod = xcconfig.gsub(/DT_TOOLCHAIN_DIR/, "TOOLCHAIN_DIR")
            File.open(xcconfig_path, "w") { |file| file << xcconfig_mod }
        end
    end
end
