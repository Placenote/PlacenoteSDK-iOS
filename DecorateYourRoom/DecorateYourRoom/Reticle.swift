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
    
    private var anchors: [ARAnchor] = []
    private var anchorNodes: [SCNNode] = []
    private var anchorIDs: [UUID] = []
    
    private var arkitf: matrix_float4x4 = matrix_identity_float4x4
    private var reticleNode: SCNNode = SCNNode()
    private var reticlePreviewNode: SCNNode = SCNNode()
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
        reticleActive = true
        sceneView = arview
    }
    
    init (arview: ARSCNView, reticle: SCNNode) {
        reticleNode = reticle
        sceneView = arview
    }
    
    /*
     func addPreviewModelToReticle (node: SCNNode)  { //attach model to reticle
     reticlePreviewNode = node
     reticleNode.addChildNode(reticlePreviewNode)
     }
     
     func removePreviewModel() {
     reticlePreviewNode.removeFromParentNode()
     }
     */
    
    //add model to plane/mesh where reticle currently is, return the reticles global position
    func addModelAtReticle (node: SCNNode) -> SCNMatrix4 {
        node.transform = SCNMatrix4Mult(reticleHitTf, node.transform)
        sceneView.scene.rootNode.addChildNode(node)
        return node.transform
    }
    
    /*
    func addPlaneNode(planeNode: SCNNode, anchor: ARAnchor) {
        anchors.append(anchor)
        anchorNodes.append(planeNode)
        anchorIDs.append(anchor.identifier)
    }
    
    func updatePlaneNode(planeNode: SCNNode, anchor: ARAnchor) {
        let idx = getAnchorIndex(id: anchor.identifier)
        if (idx > -1) {
            anchorNodes[idx] = planeNode
        }
    }
 */
    
    func updateReticle() {
        if (reticleActive) {
            let hitTestResults = sceneView.hitTest(sceneView.center, types: .featurePoint)
            if (hitTestResults.count > 0) {
                let hitResult: ARHitTestResult = hitTestResults.first!
                reticleNode.transform = SCNMatrix4(hitResult.worldTransform)
                let idx = getAnchorIndex(id: (hitResult.anchor?.identifier)!)
                if (idx < anchorNodes.count && idx > -1) {
                    sceneView.scene.rootNode.addChildNode(reticleNode)
                    reticleHit = true
                    reticleHitIdx = idx
                    reticleHitTf = reticleNode.transform
                }
                else {
                    reticleHit = false
                }
            }
            else {
                reticleNode.removeFromParentNode()
                reticleHit = false
            }
        }
    }
    
    private func getAnchorIndex(id: UUID) -> Int {
        var c_index: Int = 0
        for c_id in anchorIDs {
            if (c_id == id) {
                return c_index
            }
            c_index = c_index + 1
        }
        return -1
    }
    
    
}
