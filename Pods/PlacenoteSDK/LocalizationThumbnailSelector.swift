//
//  LocalizationThumbnailSelector.swift
//  PlacenoteSDK
//
//  Created by Yan Ma on 2019-09-13.
//

import Foundation
import VideoToolbox
import os.log

/// A helper class that takes the pose output from the LibPlacenote mapping/localization module
/// and transform the ARKit camera to align the inertial map frame while maintaining high frame rate.
public class LocalizationThumbnailSelector: PNDelegate {
  private var maxLmSize: Int = -1
  private var currThumbnail: CVPixelBuffer?
  private var uiImageView: UIImageView?
  private var thumbnailPicked: Bool = false
  
  /// Static instance of the LibPlacenote singleton
  private static var _instance = LocalizationThumbnailSelector()
  public static var instance: LocalizationThumbnailSelector {
    get {
      return _instance
    }
  }
  
  /**
   Constructor of the camera manager. Removes the camera node from its parent, and insert an intermediate
   SCNNode between the scene's rootnode and the camera node, so that we can rotate the ARKit frame to the
   LibPlacenote map frame
   
   - Parameter scene: The scene we wish the LibPlacenote camera to exist
   - Parameter cam: camera node that is controlled by ARKit
   */
  public init() {
    // IMPORTANT: need to run this line to subscribe to pose and status events
    LibPlacenote.instance.multiDelegate += self;
  }
  
  /**
   Accessor function to set the thumbnail image view to be updated by the localization thumbnail selector singleton
   
   - Parameter imageView: The image view to be updated by localization thumbnail selector
   */
  public func setUIImageView(imageView: UIImageView) {
    uiImageView = imageView
  }
  
  private func setCurrentImageAsThumbnail() {
    currThumbnail = LibPlacenote.instance.getCurrentFrame();
    if (uiImageView != nil && currThumbnail != nil) {
      uiImageView!.image = UIImage(pixelBuffer: currThumbnail!)!.rotate(radians: CGFloat(Float.pi/2))
    }
  }
  
  /**
   Callback to subscribe to pose measurements from LibPlacenote
   
   - Parameter outputPose: Inertial pose with respect to the map LibPlacenote is tracking against.
   - Parameter arkitPose: Odometry pose with respect to the ARKit coordinate frame that corresponds with 'outputPose' in time.
   */
  public func onPose(_ outputPose: matrix_float4x4, _ arkitPose: matrix_float4x4) -> Void {
    if (LibPlacenote.instance.getMode() != LibPlacenote.MappingMode.mapping) {
      return
    }
    
    if (thumbnailPicked) {
      return
    }
    
    let landmarks = LibPlacenote.instance.getTrackedLandmarks();
    if (landmarks.count > 0) {
      var lmSize: Int = 0
      for lm in landmarks {
        if (lm.maxViewAngle < 0.05 || lm.measCount < 4) {
          continue
        }
        lmSize += 1
      }
      
      if (lmSize > maxLmSize) {
        maxLmSize = lmSize
        os_log("Updated thumbnail with %d", log: OSLog.default, type: .error, maxLmSize)
        setCurrentImageAsThumbnail()
      }
    }
  }
  
  /**
   Callback to subscribe to mapping session status changes.
   
   - Parameter prevStatus: Status before the status change
   - Parameter currStatus: Current status of the mapping engine
   */
  public func onStatusChange(_ prevStatus: LibPlacenote.MappingStatus, _ currStatus: LibPlacenote.MappingStatus) {
    
  }
  
  /**
   Callback to subscribe to the first localization event for loading assets
   */
  public func onLocalized() -> Void {
  }
  
  /**
   Select current frame to be the thumbnail manually.
   */
  public func selectCurrentThumbnail() -> Bool {
    if (LibPlacenote.instance.getMode() != LibPlacenote.MappingMode.mapping) {
      // Prompt that it's not in mapping mode
      return false
    }
    
    let landmarks = LibPlacenote.instance.getTrackedLandmarks();
    if (landmarks.count == 0) {
      return false
    }
    
    var lmSize: Int = 0
    for lm in landmarks {
      if (lm.maxViewAngle < 0.05 || lm.measCount < 4) {
        continue
      }
      lmSize += 1
    }

    if (lmSize > 20) {
      thumbnailPicked = true;
      setCurrentImageAsThumbnail()
      return true
    } else {
      return false
    }
  }
  
  public func reset() {
    if (uiImageView != nil) {
      uiImageView!.image = nil
    }
    thumbnailPicked = false;
  }
  
  public func downloadThumbnail(mapId: String) {
    //let thumbnailPath: String = Path.Combine(Application.persistentDataPath, mapId + ".png");
    var thumbnailPath: String = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
    thumbnailPath = (thumbnailPath as NSString).appendingPathComponent(mapId + ".png")
    let fileManager = FileManager.default
    if fileManager.fileExists(atPath: thumbnailPath) {
      if (uiImageView != nil) {
        os_log("Thumbnail already on HD. Loading from %s", log: OSLog.default, type: .info, thumbnailPath)
        uiImageView!.image = UIImage(contentsOfFile: thumbnailPath)
      }
      return
    }
  
    // Save Render Texture into a jpg
    LibPlacenote.instance.syncLocalizationThumbnail(mapId: mapId, thumbnailPath: thumbnailPath,
      syncProgressCb: {(completed: Bool, faulted: Bool, percentage: Float) -> Void in
        if (completed) {
          os_log("Thumbnail downloaded")
          if (self.uiImageView != nil) {
            self.uiImageView!.image = UIImage(contentsOfFile: thumbnailPath)
          }
        } else if (faulted) {
          os_log("Thumbnail download failed")
        } else {
          os_log("Thumbnail downloading %f", log: OSLog.default, type: .info, percentage)
        }
      }
    );
  }
  
  public func uploadThumbnail(mapId: String) {
    var thumbnailPath: String = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
    thumbnailPath = (thumbnailPath as NSString).appendingPathComponent(mapId + ".png")
    let thumbnailUrl: URL = URL(fileURLWithPath: thumbnailPath)
    
    // write the image to thumbnail path
    if (currThumbnail == nil) {
      os_log("No thumbnail captured? Aborting thumbnail upload", log: OSLog.default, type: .error)
      return
    }
    
    guard let image = UIImage.init(pixelBuffer: currThumbnail!) else {
      os_log("Failed to convert thumbnail pixel buffer to UIImage, aborting thumbnail upload",
             log: OSLog.default, type: .error)
      return
    }
    
    let thumbnail: UIImage = image.resize(size: CGSize(width: image.size.width/3, height: image.size.height/3))!.rotate(radians: CGFloat(Float.pi/2))
    
    guard let data = UIImagePNGRepresentation(thumbnail) else {
      os_log("Failed to convert thumbnail UIImage to data buffer, aborting thumbnail upload",
             log: OSLog.default, type: .error)
      return
    }
    
    // Save Render Texture into a jpg
    do {
      try data.write(to: (thumbnailUrl as URL))
      LibPlacenote.instance.syncLocalizationThumbnail(mapId: mapId, thumbnailPath: thumbnailPath,
        syncProgressCb: {(completed: Bool, faulted: Bool, percentage: Float) -> Void in
          if (completed) {
            os_log("Thumbnail uploaded")
          } else if (faulted) {
            os_log("Thumbnail upload failed")
          } else {
            os_log("Thumbnail uploading %f", log: OSLog.default, type: .info, percentage)
          }
        });
    } catch {
      os_log("Image write failed! Error: %s", log: OSLog.default, type: .error, error.localizedDescription)
    }
  }
}
