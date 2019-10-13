# Uncomment the next line to define a global platform for your project
platform :ios, '11.0'

workspace 'PlacenoteSDKExample'
xcodeproj 'PlacenoteSDKExample.xcodeproj'
xcodeproj 'HelloWorld/HelloWorld.xcodeproj'
xcodeproj 'DecorateYourRoom/DecorateYourRoom.xcodeproj'

target 'HelloWorld' do
    use_frameworks!
    xcodeproj 'HelloWorld/HelloWorld.xcodeproj'
    pod 'PlacenoteSDK'
end

target 'DecorateYourRoom' do
  use_frameworks!
  xcodeproj 'DecorateYourRoom/DecorateYourRoom.xcodeproj'
  pod 'PlacenoteSDK'
end

target 'PlacenoteSDKExample' do
  use_frameworks!
  xcodeproj 'PlacenoteSDKExample.xcodeproj'
  pod 'PlacenoteSDK'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['ENABLE_BITCODE'] = 'NO'
    end
  end
end
