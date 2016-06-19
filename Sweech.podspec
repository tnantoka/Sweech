Pod::Spec.new do |s|
  s.name             = 'Sweech'
  s.version          = '0.1.0'
  s.summary          = 'A text-to-speech utility.'

  s.description      = <<-DESC
                       A wrapper of AVSpeechSynthesizer written in Swift.
                       DESC

  s.homepage         = 'https://github.com/tnantoka/Sweech'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'tnantoka' => 'tnantoka@bornneet.com' }
  s.source           = { :git => 'https://github.com/tnantoka/Sweech.git', :tag => "v#{s.version}" }
  s.social_media_url = 'https://twitter.com/tnantoka'

  s.ios.deployment_target = '8.0'

  s.source_files = 'Sweech/**/*.{h,swift}'
end
