//
//  CameraManager.swift
//  PlacenoteSDK
//
//  Created by Yan Ma on 2018-01-09.
//  Copyright © 2018 Vertical AI. All rights reserved.
//

import Foundation

/// A helper class that takes the pose output from the LibPlacenote mapping/localization module
/// and transform the ARKit camera to align the inertial map frame while maintaining high frame rate.
public class CameraManager: PNDelegate {
  private let verticesPerCube: Int = 36
  private var camera: SCNNode
  private var rootNode: SCNNode
  private var cameraParent: SCNNode = SCNNode()
  
  /**
   Constructor of the camera manager. Removes the camera node from its parent, and insert an intermediate
   SCNNode between the scene's rootnode and the camera node, so that we can rotate the ARKit frame to the
   LibPlacenote map frame
   
   - Parameter scene: The scene we wish the LibPlacenote camera to exist
   - Parameter cam: camera node that is controlled by ARKit
   */
  public init(scene: SCNScene, cam: SCNNode) {
    rootNode = scene.rootNode
    camera = cam
    
    rootNode.addChildNode(cameraParent)
    cameraParent.position = SCNVector3(0, 0, 0)
    cameraParent.addChildNode(camera)
    
    // IMPORTANT: need to run this line to subscribe to pose and status events
    LibPlacenote.instance.multiDelegate += self;
  }
  
  /**
   Callback to subscribe to pose measurements from LibPlacenote
   
   - Parameter outputPose: Inertial pose with respect to the map LibPlacenote is tracking against.
   - Parameter arkitPose: Odometry pose with respect to the ARKit coordinate frame that corresponds with 'outputPose' in time.
   */
  public func onPose(_ outputPose: matrix_float4x4, _ arkitPose: matrix_float4x4) -> Void {
    if (LibPlacenote.instance.getStatus() == LibPlacenote.MappingStatus.running) {
      cameraParent.simdTransform = outputPose*arkitPose.inverse
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
}
