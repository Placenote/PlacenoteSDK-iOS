# Placenote SDK iOS Sample app.
The Placenote Software development kit (SDK) allows developers to create mobile applications that are location aware indoors without the need for GPS, markers or beacons. The SDK is compatible with all ARKit enabled phones and can be used to create persistent augmented reality experiences on iOS!
The Placenote SDK iOS Sample app provided here is to serve as an example on how to integrate the SDK into a native iOS app. This app is written primarily in Swift. Questions? Comments? Issues? Come see us on [Slack](https://placenote.com/slack)

## Getting Started
* First off, you will need to create a developer account and generate an API Key on our website:
  * https://developer.placenote.com/

## How to Download and Install Placenote

### Download the .tar release package (RECOMMENDED)
* Download the latest Placenote release package from here:
  * [Latest iOS Release](https://github.com/Placenote/PlacenoteSDK-iOS/releases/latest)

* Follow the official documentation to install Placenote and build your first app:
  * [Build a sample Placenote app](https://placenote.com/docs/swift/install-sample/)

### Using this Github repository
If you prefer you can clone this repository but make sure you take note of the following:
  * Critical library files are stored using lfs, which is the large file storage mechanism for git. To Install these files, install lfs either using HomeBrew:

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

## Official Placenote Documentation
Please use the [official Placenote documentation](https://placenote.com/docs/swift/about) to learn how to build apps with Placenote.
