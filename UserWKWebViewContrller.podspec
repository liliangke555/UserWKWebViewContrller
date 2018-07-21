#
# Be sure to run `pod lib lint KYEWebViewController.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'UserWKWebViewContrller'
  s.version          = '0.0.1'
  s.summary          = 'UserWKWebViewContrller.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
封装WKWebView，支持缓存和预加载，解决WKWebview丢失cookie以及ajax的post请求丢失body的问题.
                       DESC

  s.homepage         = 'http://172.20.8.45/iOS-KYE'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'liliangke' => 'liliangke@outlook.com' }
  s.source           = { :git => 'https://github.com/liliangke555/UserWKWebViewContrller.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.source_files = 'KYEWebViewController/Classes/**/*'

  s.resource_bundles = {
     'KYEWebViewController' => ['KYEWebViewController/Assets/*.png','KYEWebViewController/Assets/*.js']
   }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
