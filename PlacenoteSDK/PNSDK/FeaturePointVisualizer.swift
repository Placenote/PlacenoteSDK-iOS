//
//  PointcloudHelper.swift
//  PlacenoteSDK
//
//  Created by Yan Ma on 2018-01-09.
//  Copyright © 2018 Vertical AI. All rights reserved.
//

import Foundation


/// A helper class that takes fetch the map of feature points from LibPlacenote
/// and visualize it as a pointcloud periodically when enabled
class FeaturePointVisualizer {
  private let verticesPerCube: Int = 36
  private var scene: SCNScene
  private var ptcloudNode: SCNNode = SCNNode()
  private var ptcloudTimer: Timer = Timer()
  
  /**
   Constructor that appends the the scene as an input and append a node containing the pointcloud geometry in it
   
   - Parameter inputScene: the scene where pointcloud is to rendered
   */
  init(inputScene: SCNScene) {
    scene = inputScene
    scene.rootNode.addChildNode(ptcloudNode)
  }
  
  /**
   A function to enable visualization of the map pointcloud
   */
  func enableFeaturePoints() {
    ptcloudTimer = Timer.scheduledTimer(
        timeInterval: 0.5, target: self,
        selector: #selector(FeaturePointVisualizer.drawPointcloud),
        userInfo: nil, repeats: true
    )
  }
  
  /**
   A function to disable visualization of the map pointcloud
   */
  func disableFeaturePoints() {
    ptcloudTimer.invalidate()
    reset();
  }
  
  /**
   A function to reset the pointcloud visualization
   */
  func reset() {
    ptcloudNode.removeFromParentNode()
  }
  
  /**
   Function to be called periodically to draw the pointcloud geometry
   */
  @objc private func drawPointcloud() {
    if (LibPlacenote.instance.getMappingStatus() == LibPlacenote.MappingStatus.running) {
      let landmarks = LibPlacenote.instance.getAllLandmarks();
      if (landmarks.count > 0) {
        addPointcloud(landmarks: landmarks)
      }
    }
  }
  
  /**
   Function to that draws a pointcloud as a set of cubes from the input feature point array
   
   - Parameter landmarks: an array of feature points in the inertial map frame to be rendered
   */
  private func addPointcloud(landmarks: Array<PNFeaturePoint>) { //TODO: Only works with OpenGL (where ARKit doesn't work)
    var vertices : [SCNVector3] = [SCNVector3]()
    var normals: [SCNVector3] = [SCNVector3]()
    var colors: [SCNVector3] = [SCNVector3]()
    
    vertices.reserveCapacity(landmarks.count*verticesPerCube)
    normals.reserveCapacity(landmarks.count*verticesPerCube)
    colors.reserveCapacity(landmarks.count*verticesPerCube)
    for lm in landmarks {
      if (lm.measCount < 4) {
        continue
      }
      
      let pos:SCNVector3 = SCNVector3(x: lm.point.x, y: lm.point.y, z: lm.point.z)
      getCube(position: pos, size: 0.01, resultCb: {(cubeVerts: [SCNVector3], cubeNorms: [SCNVector3]) -> Void in
        vertices += cubeVerts
        normals += cubeNorms
      })
      
      let color = SCNVector3(x: 1 - Float(lm.measCount)/10, y: Float(lm.measCount)/10, z: 0.0)
      for _ in 0...(verticesPerCube - 1) {
        colors.append(color)
      }
    }
    
    let indices = vertices.enumerated().map{Int32($0.0)}
    let vertexSource = SCNGeometrySource(vertices: vertices)
    let normalSource = SCNGeometrySource(normals: normals)
    let colorData = NSData(bytes: UnsafeRawPointer(colors), length: MemoryLayout<SCNVector3>.size * colors.count)
    let colorSource: SCNGeometrySource = SCNGeometrySource(data: colorData as Data,
        semantic: SCNGeometrySource.Semantic.color, vectorCount: colors.count,
        usesFloatComponents: true, componentsPerVector: 3, bytesPerComponent: MemoryLayout<Float>.size,
        dataOffset: 0, dataStride: MemoryLayout<SCNVector3>.size
    )
    
    let indexData = NSData(bytes: UnsafeRawPointer(indices), length: MemoryLayout<Int32>.size * indices.count)
    let element = SCNGeometryElement(data: indexData as Data, primitiveType: .triangles,
                                     primitiveCount: indices.count/3, bytesPerIndex: MemoryLayout<Int32>.size)
    let pointCloud = SCNGeometry(sources: [vertexSource, normalSource, colorSource], elements: [element])
    
    ptcloudNode.removeFromParentNode()
    ptcloudNode = SCNNode(geometry: pointCloud)
    scene.rootNode.addChildNode(ptcloudNode)
  }
  
  
  /**
   Returns vertices and normals for a cube mesh given the center point and the size
   
   - Parameter position: position vector of the center point of the cube
   - Parameter size: length of the edge in a cube
   - Parameter resultCb: callback to return the vertices and normal for the resulting cube
   */
  private func getCube(position: SCNVector3, size: Float, resultCb: (_ vertices: [SCNVector3], _ normals: [SCNVector3]) -> Void) {
    let halfEdge = size/2
    let v0 = SCNVector3(x: -halfEdge + position.x, y: -halfEdge + position.y, z: halfEdge + position.z)
    let v1 = SCNVector3(x: halfEdge + position.x,  y: -halfEdge + position.y, z: halfEdge + position.z)
    let v2 = SCNVector3(x: halfEdge + position.x,  y: halfEdge + position.y,  z: halfEdge + position.z)
    let v3 = SCNVector3(x: -halfEdge + position.x, y: halfEdge + position.y,  z: halfEdge + position.z)
    let v4 = SCNVector3(x: -halfEdge + position.x, y: -halfEdge + position.y, z: -halfEdge + position.z)
    let v5 = SCNVector3(x: halfEdge + position.x,  y: -halfEdge + position.y, z: -halfEdge + position.z)
    let v6 = SCNVector3(x: -halfEdge + position.x, y: halfEdge + position.y,  z: -halfEdge + position.z)
    let v7 = SCNVector3(x: halfEdge + position.x,  y: halfEdge + position.y,  z: -halfEdge + position.z)
    
    let vertices: [SCNVector3] = [
      // front face
      v0, v1, v3, v0, v1, v2,
      // right face
      v1, v7, v2, v1, v5, v7,
      // back face
      v5, v6, v7, v5, v4, v6,
      // left face
      v4, v3, v6, v4, v0, v3,
      // top face
      v3, v7, v6, v3, v2, v7,
      // bottom face
      v1, v4, v5, v1, v0, v4
    ]
    
    let normalsPerFace = 6
    let xUnitVec = SCNVector3(x: 1, y: 0, z: 0)
    let negXUnitVec = SCNVector3(x: -1, y: 0, z: 0)
    let yUnitVec = SCNVector3(x: 0, y: 1, z: 0)
    let negYUnitVec = SCNVector3(x: 0, y: -1, z: 0)
    let zUnitVec = SCNVector3(x: 0, y: 0, z: 1)
    let negZUnitVec = SCNVector3(x: 0, y: 0, z: -1)
    
    let normals: [SCNVector3] = [
      zUnitVec, xUnitVec, negZUnitVec, negXUnitVec, yUnitVec, negYUnitVec
      ].map{[SCNVector3](repeating: $0, count: normalsPerFace)}.flatMap{$0}
    resultCb(vertices, normals)
  }
}
