Pod::Spec.new do |s|

s.name         = "ExtentionSDK"
s.version      = "0.0.1"
s.summary      = "ExtentionSDK"
s.license      = { :type => "MIT", :file => "LICENSE" }

s.description  = <<-DESC
Swift扩展和常用插件。
DESC

#提交到Gitee的私有空间（为啥不提交到GitHub，因为墙！😭）
s.homepage      = "https://gitee.com/timenode-wuhan/extentionsdk"
s.author        = { "龚洪" => "864797268@qq.com" }
s.platform      = :ios, "11.0"
s.source        = { :git => "https://gitee.com/timenode-wuhan/extentionsdk.git", :tag => s.version }

s.vendored_frameworks = 'ExtentionSDK.framework'

# 让SDK支持真机和模拟器
s.pod_target_xcconfig = { 'VALID_ARCHS' => 'x86_64 armv7 arm64' }


# 需要的其他三方库
s.dependency 'IQKeyboardManagerSwift'
s.dependency 'MJRefresh'
s.dependency 'lottie-ios'
s.dependency 'SwifterSwift'
s.dependency 'SnapKit'


end

