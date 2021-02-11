Pod::Spec.new do |spec|

  spec.name         = "Messaging-InApp-Core"
  spec.version      = "0.5.0"
  spec.summary      = "A short description of Messaging-InApp-Core."

  spec.homepage     = "http://EXAMPLE/Messaging-InApp-Core"
  spec.license      = { :type => "BSD", :file => "License.md" }
  spec.author       = { "Jeremy Wright" => "jeremy.wright@salesforce.com" }
  spec.platform     = :ios, "13.0"
  spec.source       = { :http => "https://in-app-deploy-test.s3.amazonaws.com/ios/in-app-sdk/0.5.0/Test.zip" }

  spec.vendored_frameworks = 'Frameworks/IAMessagingCore.xcframework'

  spec.requires_arc = true
end
