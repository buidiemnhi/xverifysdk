# Uncomment the next line to define a global platform for your project
# platform :ios, '13.0'
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
