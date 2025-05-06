#
# Be sure to run `pod lib lint IOSCommon.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'IOSCommon'
  s.version          = '0.1.0'
  s.summary          = 'A short description of IOSCommon.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
ios common lib
                       DESC

  s.homepage         = 'https://gitlab.boostvision.com.cn/delta/ios/infra/IOSCommon'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Tay' => 'lei@boostvision.com.cn' }
  s.source           = { :git => 'https://gitlab.boostvision.com.cn/delta/ios/infra/IOSCommon.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '13.0'

  s.source_files = 'IOSCommon/Classes/**/*'
  
  # s.resource_bundles = {
  #   'IOSCommon' => ['IOSCommon/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
  s.dependency 'KeychainSwift'
  s.dependency 'LLNetworkAccessibility-Swift'
end
