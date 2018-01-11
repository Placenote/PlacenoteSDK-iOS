//
//  ShapeType.swift
//  Shape Dropper (Placenote SDK iOS Sample)
//
//  Created by Prasenjit Mukherjee on 2017-08-27.
//  Copyright © 2017 Vertical AI. All rights reserved.
//

import Foundation

public enum ShapeType:Int {
  
  case Box = 0
  case Sphere
  case Pyramid
  case Torus
  case Capsule
  case Cylinder
  case Cone
  case Tube
  
  static func random() -> ShapeType {
    let maxValue = Tube.rawValue
    let rand = arc4random_uniform(UInt32(maxValue+1))
    return ShapeType(rawValue: Int(rand))!
  }
  
  
  static func generateGeometry(s_type:ShapeType) -> SCNGeometry {
    
    let geometry: SCNGeometry
    
    switch s_type {
    case ShapeType.Sphere: //
      geometry = SCNSphere(radius: 1.0)
    case ShapeType.Capsule:
      geometry = SCNCapsule(capRadius:0.5, height:1.0)
    case ShapeType.Cone:
      geometry = SCNCone(topRadius:0, bottomRadius:0.5, height:1.0)
    case ShapeType.Cylinder:
      geometry = SCNCylinder(radius:0.5, height:1.0)
    case ShapeType.Pyramid:
      geometry = SCNPyramid(width:1.0, height:1.0, length:1.0)
    case ShapeType.Torus:
      geometry = SCNTorus(ringRadius:1.0, pipeRadius:0.1)
    case ShapeType.Box: //
      fallthrough
    default:
      geometry = SCNBox(width: 1.0, height: 1.0, length: 1.0, chamferRadius: 0.1)
    }
    
    return geometry
  }
}

