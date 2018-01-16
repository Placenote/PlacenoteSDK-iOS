# Placenote SDK iOS Sample app.
The Placenote Software development kit (SDK) allows developers to create mobile applications that are location aware indoors, in and around complex buildings and with respect to instruments and machinery without the need for GPS, markers or beacons. The SDK is compatible with all ARKit enabled phones and can be used to create persistent augmented reality experiences on iOS!
The Placenote SDK iOS Sample app provided here is to serve as an example on how to integrate the SDK into a native iOS app. This app is written primarily in Swift.

## Getting Started
* Clone this repository
  * Critical library files are stored using lfs, which is the large file storage mechanism for git.
  * To Install these files install lfs either using HomeBrew: `brew install git-lfs` or MacPorts: `port install git-lfs`
  * After you have cloned this repository, additionally run `git lfs install` and then `git lfs pull`
  * More details can be found on the [git lfs website](https://git-lfs.github.com/)
* Get an API key from: https://developer.placenote.com/
* Place API key in the bridging header: PlacenoteSDK-Bridging-Header.h
* Run Sample App. Note that within XCode, the library cannot be compiled for simulation and will throw Linker errors. ARKit is also currently incompatible with running in simulation. Please attach hardware and run the sample app on that!

To integrate this into your own app
* Add all the files under the PNSDK folder and PlacenoteSDK-Bridging-header.h into your project
* Make sure the library files (libopencv.a and libPlacenote.a) are listed under 'Linked Frameworks and Libraries' under the 'General' tab. This should be automatic
* Add the libstdc++.tbd library in the 'Linked Frameworks and Libraries' section under the 'General' tab. This will aid in the cross-compilation and linking of C++ libraries
* Read further API documentation here: https://developer.placenote.com/api/swift/
