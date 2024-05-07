Pod::Spec.new do |s|  
    s.name              = 'verifysdk' # Name for your pod
    s.version           = '0.0.1'
    s.summary           = 'An sdk to verify chip-mounted ID card'
    s.homepage          = 'https://www.google.com'

    s.author            = { 'Sample' => 'buidiemnhi@gmail.com' }
    s.license = { :type => "MIT", :text => "MIT License" }

    s.platform          = :ios
    # change the source location
    s.source            = { :http => 'https://github.com/buidiemnhi/xverifysdk.git', :branch => 'main' } 
    s.ios.deployment_target = '13.0'
    # 8 Khai báo file code 
    s.source_files = "xverifysdk/**/*.{h,m}"
    s.source_files = "xverifysdk/**/*.{swift}"
    s.resources = "xverifysdk/**/*.{png,jpeg,jpg,storyboard,xib}"
    s.dependency 'Alamofire', '~> 5.8.1'
    s.dependency 'OpenSSL-Universal', '~> 1.1.2200'
    s.dependency 'CocoaLumberjack/Swift'
    s.dependency 'ObjectMapper'
    s.dependency 'SwiftDate'
    s.dependency 'PINCache'
    s.dependency 'GoogleMLKit/Vision'
    s.dependency 'GoogleMLKit/FaceDetection'
    s.dependency 'GoogleMLKit/TextRecognition'
end 
