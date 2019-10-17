//
//  LocalizationThumbnailSelector.swift
//  PlacenoteSDK
//
//  Created by Yan Ma on 2019-09-13.
//

import Foundation
import VideoToolbox
import os.log

/// A helper class that selects a localization thumbnail for the current map by picking the frame that tracks
/// the most good features
public class LocalizationThumbnailSelector: PNDelegate {
  private var maxLmSize: Int = -1
  private var newThumbnailEvent: Event<UIImage?> = Event<UIImage?>()
  
  /// accessor to new thumbnail event to return the latest thumbnail texture for visualization purposes
  public var onNewThumbnail: Event<UIImage?> {
    get {
      return newThumbnailEvent
    }
  }
  
  /**
   Constructor.
   */
  public init() {
    // IMPORTANT: need to run this line to subscribe to pose and status events
    LibPlacenote.instance.multiDelegate += self;
  }
  
  private func setCurrentImageAsThumbnail() {
    LibPlacenote.instance.setLocalizationThumbnail();
    LibPlacenote.instance.getLocalizationThumbnail(thumbnailCb: {(thumbnail: UIImage?) -> Void in
      self.newThumbnailEvent.raise(data: thumbnail)
    });
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
    
    let landmarks = LibPlacenote.instance.getTrackedFeatures();
    if (landmarks.count > maxLmSize) {
      maxLmSize = landmarks.count
      os_log("Updated thumbnail with %d", log: OSLog.default, type: .error, maxLmSize)
      setCurrentImageAsThumbnail()
    }
  }
  
  /**
   Callback to subscribe to mapping session status changes.
   
   - Parameter prevStatus: Status before the status change
   - Parameter currStatus: Current status of the mapping engine
   */
  public func onStatusChange(_ prevStatus: LibPlacenote.MappingStatus, _ currStatus: LibPlacenote.MappingStatus) {
    if (prevStatus != LibPlacenote.MappingStatus.waiting && currStatus == LibPlacenote.MappingStatus.waiting) {
      maxLmSize = -1;
    }
    else if (prevStatus == LibPlacenote.MappingStatus.waiting) {
      if (LibPlacenote.instance.getMode() == LibPlacenote.MappingMode.localizing) {
        LibPlacenote.instance.getLocalizationThumbnail(thumbnailCb: {(thumbnail: UIImage?) -> Void in
          self.newThumbnailEvent.raise(data: thumbnail)
        });
      }
    }
  }
  
  /**
   Callback to subscribe to the first localization event for loading assets
   */
  public func onLocalized() -> Void {
  }
}
