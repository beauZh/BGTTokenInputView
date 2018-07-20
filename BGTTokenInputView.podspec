#
# Be sure to run `pod lib lint BGTTokenInputView.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'BGTTokenInputView'
  s.version          = '0.1.0'
  s.summary          = 'A custom TokenView which is similar to iMessage To function. This code is a swift3 rewrite of CLTokenInputView.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
This is a TokenView which is similar to iMessage To function. The original code is a Object-C code from https://github.com/clusterinc/CLTokenInputView. There is also a Swift3 version https://github.com/lauracpierre/FA_TokenInputView. This code is basically from it. Some functions are deleted, and some bugs are fixed. Install library into project, never have to wrtie these code again.
                       DESC

  s.homepage         = 'https://github.com/beauZh/BGTTokenInputView'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'beauzhang@live.ca' => 'beauzhang@live.ca' }
  s.source           = { :git => 'https://github.com/beauZh/BGTTokenInputView.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.swift_version = '3.2'

  s.source_files = 'BGTTokenInputView/Classes/**/*'
  
  # s.resource_bundles = {
  #   'BGTTokenInputView' => ['BGTTokenInputView/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  s.frameworks = 'UIKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
