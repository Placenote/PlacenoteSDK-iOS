# Placenote SDK iOS Sample app.
The Placenote Software development kit (SDK) allows developers to create mobile applications that are location aware indoors, in and around complex buildings and with respect to instruments and machinery without the need for GPS, markers or beacons. The SDK is compatible with all ARKit enabled phones and can be used to create persistent augmented reality experiences on iOS!
The Placenote SDK iOS Sample app provided here is to serve as an example on how to integrate the SDK into a native iOS app. This app is written primarily in Swift.

## Getting Started
* Clone this repository (note that there are files stored using lfs)
* Get an API key from: https://developer.placenote.com/
* Place API key in the bridging header: PlacenoteSDK-Bridging-Header.h
* Run Sample App in xcode

To integrate this into your own app
* Add all the files under the PNSDK folder and PlacenoteSDK-Bridging-header.h into your project
* Make sure the library files (libopencv.a and libPlacenote.a) are listed under 'Linked Frameworks and Libraries'. This should be automatic
* Add the libstdc++.tbd library to aid in the cross-compilation and linking of C++ libraries
* Read further API documentation here: https://developer.placenote.com/api/swift/

