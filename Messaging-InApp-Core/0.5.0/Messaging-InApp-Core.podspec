Pod::Spec.new do |spec|

  spec.name         = "Messaging-InApp-Core"
  spec.version      = "0.5.0"
  spec.summary      = "Core iOS framework for 'Messaging For In-App'"

  spec.homepage     = "https://developer.salesforce.com/"
  spec.license      = { :type => "BSD", :file => "LICENSE.md" }
  spec.author       = { "Jeremy Wright" => "jeremy.wright@salesforce.com" }
  spec.platform     = :ios, "13.0"
  spec.source       = { :http => "https://in-app-deploy-test.s3.amazonaws.com/ios/in-app-sdk/0.5.0/IAMessagingCore-Release.xcframework.zip" }

  spec.vendored_frameworks = 'IAMessagingCore.xcframework'

  spec.requires_arc = true
end
