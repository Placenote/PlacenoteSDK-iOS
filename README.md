# Placenote SDK iOS Sample app.
The Placenote Software development kit (SDK) allows developers to create mobile applications that are location aware indoors, in and around complex buildings and with respect to instruments and machinery without the need for GPS, markers or beacons. The SDK is compatible with all ARKit enabled phones and can be used to create persistent augmented reality experiences on iOS!
The Placenote SDK iOS Sample app provided here is to serve as an example on how to integrate the SDK into a native iOS app. This app is written primarily in Swift. Questions? Comments? Issues? Come see us on [Slack](https://join.slack.com/t/placenotedevs/shared_invite/enQtMjk5ODk2MzM0NDMzLTIzMjQwZTAxMzYxYWMyMjY1NzZmYTA2YjY0OGU5NzAzNjUxN2M1ZTQ1ZWZiYzI4ZDg4NGU1ZjQ0ZTA4NDY0OWI)

## Getting an API Key
* Get an API key from: https://developer.placenote.com/

## Getting started with the Sample
* Clone this repository
* Critical library files are stored using lfs, which is the large file storage mechanism for git.
  * To Install these files, install lfs either using HomeBrew:
  
     ```Shell Session 
     brew install git-lfs
     ```

      or MacPorts: 
      ```Shell Session
      port install git-lfs
      ```
   
  * And then, to get the library files, run: 
     ```Shell Session
     git lfs install 
     git lfs pull
     ```
  * More details can be found on the [git lfs website](https://git-lfs.github.com/)
* Place API key in the AppDelegate.swift
* Run Sample App. Note that within XCode, the library cannot be compiled for simulation and will throw Linker errors. ARKit is also currently incompatible with running in simulation. Please attach hardware and run the sample app on that!

## Getting started with your own project

### Using CocoaPods (recommended)

* If you aren't already using CocoaPods, follow the directions here to install and set it up: https://guides.cocoapods.org/using/getting-started.html
* Add `pod 'PlacenoteSDK'` to your Podfile
* We recommend automatically disabling bitcode by adding this to the end of your Podfile:
```ruby
post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['ENABLE_BITCODE'] = 'NO'
    end
  end
end
```
* Run `pod install` to install the PlacenoteSDK pod
* Disable Bitcode for your project: Under 'Build Settings' set 'Enable Bitcode' to NO
* Follow the example in the sample AppDelegate.swift for importing and initializing Placenote

### Using git (if you don't want to use CocoaPods)
* Start by following the instruction to get the sample app
* Add all the files under the Pods/PlacenoteSDK folder into your project
    * Make sure you choose to 'Create Groups' instead of 'Create Folder References'
    * The PlacenoteSDK folder should appear yellow, not blue
* Make sure the framework (Placenote.framework) is listed under 'Linked Frameworks and Libraries' under the 'General' tab. This should be automatic
* Make sure the framework (Placenote.framework) is listed under 'Embedded Binaries' under the 'General' tab.
* Under 'Build Settings' set 'Enable Bitcode' to NO
* Under 'Build Settings' add '$(PROJECT_DIR)/YOUR_PROJECT_NAME/PNSDK/Placenote.framework/Headers/' to Header Search Paths
    * The path may be different based on where you copied the PlacenoteSDK folder to
* Add the PlacenoteSDK bridging header
    * If you have an existing bridging header:
        * Add '#import "PlacenoteSDK-Bridging-Header.h"' to your project's bridging header
    * If you don't have an existing bridging header:
        * Under 'Build Settings' set 'Objective-C Bridging Header' to '$(PROJECT_DIR)/YOUR_PROJECT_NAME/PlacenoteSDK-Bridging-Header.h'
* Read further API documentation here: https://developer.placenote.com/api/swift/

