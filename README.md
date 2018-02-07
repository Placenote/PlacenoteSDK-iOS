# Placenote SDK iOS Sample app.
The Placenote Software development kit (SDK) allows developers to create mobile applications that are location aware indoors, in and around complex buildings and with respect to instruments and machinery without the need for GPS, markers or beacons. The SDK is compatible with all ARKit enabled phones and can be used to create persistent augmented reality experiences on iOS!
The Placenote SDK iOS Sample app provided here is to serve as an example on how to integrate the SDK into a native iOS app. This app is written primarily in Swift. Questions? Comments? Issues? Come see us on [Slack](https://join.slack.com/t/placenotedevs/shared_invite/enQtMjk5ODk2MzM0NDMzLTIzMjQwZTAxMzYxYWMyMjY1NzZmYTA2YjY0OGU5NzAzNjUxN2M1ZTQ1ZWZiYzI4ZDg4NGU1ZjQ0ZTA4NDY0OWI)

## Getting Started
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
* Get an API key from: https://developer.placenote.com/
* Place API key in the bridging header: PlacenoteSDK-Bridging-Header.h
* Switch the build scheme to build the app in Release mode for optimal performance
* Run Sample App. Note that within XCode, the library cannot be compiled for simulation and will throw Linker errors. ARKit is also currently incompatible with running in simulation. Please attach hardware and run the sample app on that!

To integrate this into your own app
* Add all the files under the PNSDK folder and PlacenoteSDK-Bridging-header.h into your project
    * Make sure you choose to 'Create Groups' instead of 'Create Folder References'
    * The PNSDK folder should appear yellow, not blue
* Make sure the framework (Placenote.framework) is listed under 'Linked Frameworks and Libraries' under the 'General' tab. This should be automatic
* Make sure the framework (Placenote.framework) is listed under 'Embedded Binaries' under the 'General' tab.
* Under 'Build Settings' set 'Enable Bitcode' to NO
* Under 'Build Settings' add '$(PROJECT_DIR)/YOUR_PROJECT_NAME/PNSDK/Placenote.framework/Headers/' to Header Search Paths
    * The path may be different based on where you copied the PNSDK folder to
* Add the PNSDK bridging header
    * If you have an existing bridging header:
        * Add '#import "PlacenoteSDK-Bridging-Header.h"' to your project's bridging header
    * If you don't have an existing bridging header:
        * Under 'Build Settings' set 'Objective-C Bridging Header' to '$(PROJECT_DIR)/YOUR_PROJECT_NAME/PlacenoteSDK-Bridging-Header.h'
* Read further API documentation here: https://developer.placenote.com/api/swift/

