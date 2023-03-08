#
# Be sure to run `pod lib lint Coordinator.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'ChidoriMenu'
  s.version          = '0.0.0'#`git describe --abbrev=0 --tags`
  s.summary          = 'Popup menu like in iOS 14'
  s.description      = 'Popup menu like in iOS 14. Based on christianselig/ChidoriMenu'

  s.homepage         = 'https://github.com/lumyk/ChidoriMenu'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Evgeny Kalashnikov' => 'lumyk@me.com' }
  s.source           = { :git => 'https://github.com/lumyk/ChidoriMenu.git', :tag => s.version.to_s }

  s.ios.deployment_target = '13.0'

  s.source_files = 'Sources/**/*'
  s.swift_version = '5.0'
end
