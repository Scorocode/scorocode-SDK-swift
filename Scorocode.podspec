Pod::Spec.new do |s|
  s.name             = 'Scorocode'
  s.version          = '0.4'
  s.summary          = 'Scorocode ios SDK, swift 3'
 
  s.description      = <<-DESC
SDK предоставляет доступ к платформе Scorocode для построения приложений, основанных на swift. 
Подробности на нашем сайте: https://scorocode.ru
                       DESC
  s.homepage         = 'https://github.com/Scorocode/scorocode-SDK-swift'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Alexey Kuznetsov' => 'alexey073@gmail.com' }
  s.source           = { :git => 'https://github.com/Scorocode/scorocode-SDK-swift.git', :tag => s.version.to_s }

  s.ios.deployment_target = '8.0'
  s.source_files = 'Scorocode/SCLib/**/*'
 
end

