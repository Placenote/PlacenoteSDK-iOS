//
//  Reticle.swift
//  DecorateYourRoom
//
//  Created by Neil Mathew on 10/13/19.
//  Copyright © 2019 Placenote. All rights reserved.
//

import Foundation
import ARKit

class Reticle {
    

    private var reticleNode: SCNNode = SCNNode()

    private var reticleActive: Bool = false
    private var reticleHit: Bool = false
    private var reticleHitIdx: Int = -1
    private var reticleHitTf: SCNMatrix4 = SCNMatrix4Identity
    
    private var sceneView: ARSCNView
    
    init() {
        sceneView = ARSCNView()
    }
    
    init(arview: ARSCNView) { //default initializer and default red reticle
        let reticleGeo: SCNGeometry = SCNCylinder(radius: 0.06, height: 0.005)
        reticleGeo.materials.first?.diffuse.contents = UIColor.red
        reticleNode = SCNNode(geometry: reticleGeo)
        reticleNode.opacity = 0.4
        reticleNode.isHidden = true
        reticleActive = false
        sceneView = arview
        sceneView.scene.rootNode.addChildNode(reticleNode)
    }
    
    init (arview: ARSCNView, reticle: SCNNode) {
        reticleNode = reticle
        sceneView = arview
    }

    public func activateReticle()
    {
        print ("Reticle activated")
        reticleActive = true
        reticleNode.isHidden = false
        
    }
    
    public func deactivateReticle()
    {
        print ("Reticle deactivated")
        reticleActive = false
        reticleNode.isHidden = true
    }
    
    func getReticlePosition () -> SCNVector3 {
        return reticleNode.position
    }
    
    func getReticleRotation () -> SCNVector4 {
        return reticleNode.rotation
    }
    
    // this moves the reticle based on the hittest
    func updateReticle() {
        
        if (reticleActive) {
            
            let hitTestResults = sceneView.hitTest(sceneView.center, types: .existingPlaneUsingExtent)
            if (hitTestResults.count > 0) {
                let hitResult: ARHitTestResult = hitTestResults.first!
                reticleNode.transform = SCNMatrix4(hitResult.worldTransform)
                reticleNode.isHidden = false
                reticleHit = true
            }
            else {

                reticleHit = false
                reticleNode.isHidden = true
            }
        }
    }
    
    
}
