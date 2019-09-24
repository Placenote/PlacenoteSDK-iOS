//
//  MulticastDelegate.swift
//  PlacenoteSDK referenced from http://www.gregread.com/2016/02/23/multicast-delegates-in-swift/#Option_2_8211_A_Better_Way
//
//  Created by Yan Ma on 2018-01-09.
//  Copyright © 2018 Vertical AI. All rights reserved.
//

import Foundation


/// A helper class that wraps around multiple PNDelegates to with convenient
/// utility operators to append and remove delegates to/from the list
public class MulticastPNDelegate {
  private var delegates = [PNDelegate]()
  
  /**
   A function to append delegate to the multicast delegate
   
   - Parameter delegate: A PNDelegate to be appended
   */
  public func addDelegate(delegate: PNDelegate) {
    // If delegate is a class, add it to our weak reference array
    delegates.append(delegate)
  }
  
  /**
   A function to remove delegate to the multicast delegate
   
   - Parameter delegate: A PNDelegate to be removed
   */
  public func removeDelegate(delegate: PNDelegate) {
    for (index, delegateInArray) in delegates.enumerated().reversed() {
      // If we have a match, remove the delegate from our array
      if ((delegateInArray as AnyObject) === (delegate as AnyObject)) {
        delegates.remove(at: index)
      }
    }
  }
  
  /**
   Callback to subscribe to pose measurements from LibPlacenote and broadcast it to the subscribed child delegates
   
   - Parameter outputPose: Inertial pose with respect to the map LibPlacenote is tracking against.
   - Parameter arkitPose: Odometry pose with respect to the ARKit coordinate frame that corresponds with 'outputPose' in time.
   */
  func onPose(outputPose: matrix_float4x4, arkitPose: matrix_float4x4) -> Void {
    for del in delegates {
      del.onPose(outputPose, arkitPose)
    }
  }
  
  /**
   Callback to subscribe to mapping session status changes and broadcast it to the subscribed child delegates
   
   - Parameter prevStatus: Status before the status change
   - Parameter currStatus: Current status of the mapping engine
   */
  func onStatusChange(prevStatus: LibPlacenote.MappingStatus, currStatus: LibPlacenote.MappingStatus) -> Void {
    for del in delegates {
      del.onStatusChange(prevStatus, currStatus)
    }
  }
  
  /**
   Callback to subscribe to the first localization event for loading assets
   */
  func onLocalized() -> Void {
    for del in delegates {
      del.onLocalized()
    }
  }
}

/**
 += operator to append delegate to the multicast delegate
 
 - Parameter delegate: A PNDelegate to be appended
 */
public func += (left: MulticastPNDelegate, right: PNDelegate) {
  left.addDelegate(delegate: right)
}

/**
 -= operatorto remove delegate to the multicast delegate
 
 - Parameter delegate: A PNDelegate to be removed
 */
public func -= (left: MulticastPNDelegate, right: PNDelegate) {
  left.removeDelegate(delegate: right)
}
