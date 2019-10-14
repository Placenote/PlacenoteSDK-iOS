//
//  ModelManager.swift
//  DecorateYourRoom
//
//  Created by Neil Mathew on 10/13/19.
//  Copyright © 2019 Placenote. All rights reserved.
//

import Foundation
import SceneKit
import ARKit

// Struct to hold the model data
struct ModelInfo {
    public var modelType: Int = 0
    public var modelPosition: SCNVector3 = SCNVector3(0,0,0)
    public var modelRotation: SCNVector4 = SCNVector4(0,0,0,0)
}


// Main model manager class.
class ModelManager {
    
    // to hold the scene details
    private var sceneView: ARSCNView!
    
    // arrays to hold the model data
    private var modelInfoArray: [ModelInfo] = []
    private var modelNodeArray: [SCNNode] = []
    
    // variable that holds a static list of model paths
    private var modelNames: [String] = ["WoodChair/CHAHIN_WOODEN_CHAIR.scn",
                                        "Plant/PUSHILIN_plant.scn",
                                        "BlueLamp/model-triangulated.scn",
                                        "Gramophone/model-triangulated.scn"]
    
    
    // constructor that sets the scene
    init() {
    }
    
    public func setScene (view: ARSCNView) {
        sceneView = view
    }
    
    //add model to plane/mesh where reticle currently is, return the reticles global position
    public func addModelAtPose (pos: SCNVector3, rot: SCNVector4, index: Int) {
        
        // turn the scn file into a node
        let node = getModel(modelIndex: index)
        
        node.position = pos
        node.scale = SCNVector3(x:0.8, y:0.8, z:0.8)
        
        // not using the rotation actually. Instead we are setting the rotation to look at the camera
        let targetLookPos = SCNVector3(x: (sceneView?.pointOfView!.position.x)!, y: node.position.y, z: (sceneView.pointOfView?.position.z)!)
        node.look(at: targetLookPos)
        
        // add node to the scene
        sceneView.scene.rootNode.addChildNode(node)
        
        // add node the storage data structures
        let newModel: ModelInfo = ModelInfo(modelType: index, modelPosition: node.position, modelRotation: node.rotation)
        
        // add model to model list and model node list
        modelInfoArray.append(newModel)
        modelNodeArray.append(node)
        
    }
    
    // turn the scn file into a node
    func getModel (modelIndex: Int) -> SCNNode {
        let fileNodes = SCNScene(named: "art.scnassets/" + modelNames[modelIndex])
        let node = SCNNode()
        for child in (fileNodes?.rootNode.childNodes)! {
            node.addChildNode(child)
        }
        print ("created model from " + modelNames[modelIndex])
        return node
    }
    
    // turn the model array into a json object
    func getModelInfoJSON() -> [[String: [String: String]]]
    {
        var modelInfoJSON: [[String: [String: String]]] = []
        
        if (modelInfoArray.count > 0)
        {
            for i in 0...(modelInfoArray.count-1)
            {
                modelInfoJSON.append(["model": ["type": "\(modelInfoArray[i].modelType)", "px": "\(modelInfoArray[i].modelPosition.x)",  "py": "\(modelInfoArray[i].modelPosition.y)",  "pz": "\(modelInfoArray[i].modelPosition.z)", "qx": "\(modelInfoArray[i].modelRotation.x)", "qy": "\(modelInfoArray[i].modelRotation.y)", "qz": "\(modelInfoArray[i].modelRotation.z)", "qw": "\(modelInfoArray[i].modelRotation.w)" ]])
            }
        }
        return modelInfoJSON
    }
    

    // Load shape array
    func loadModelArray(modelArray: [[String: [String: String]]]?) -> Bool {

        clearModels()
        
        if (modelArray == nil) {
            print ("Model Manager: No models in this map")
            return false
        }

        for item in modelArray! {
            let px_string: String = item["model"]!["px"]!
            let py_string: String = item["model"]!["py"]!
            let pz_string: String = item["model"]!["pz"]!
            
            let qx_string: String = item["model"]!["qx"]!
            let qy_string: String = item["model"]!["qy"]!
            let qz_string: String = item["model"]!["qz"]!
            let qw_string: String = item["model"]!["qw"]!
            
            let position: SCNVector3 = SCNVector3(x: Float(px_string)!, y: Float(py_string)!, z: Float(pz_string)!)
            let rotation: SCNVector4 = SCNVector4(x: Float(qx_string)!, y: Float(qy_string)!, z: Float(qz_string)!, w: Float(qw_string)!)
            let type: Int = Int(item["model"]!["type"]!)!
            
            addModelAtPose(pos: position, rot: rotation, index: type)

            print ("Model Manager: Retrieved " + String(describing: type) + " type at position" + String (describing: position))
        }

        print ("Model Manager: retrieved " + String(modelInfoArray.count) + " models")
        return true
    }
    
    //clear shapes from scene
    func clearView() {
        for node in modelNodeArray {
            node.removeFromParentNode()
        }
    }
    
    // delete all models from scene and model lists
    func clearModels() {
        clearView()
        modelNodeArray.removeAll()
        modelInfoArray.removeAll()
    }
    
}
