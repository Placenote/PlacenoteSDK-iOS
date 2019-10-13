//
//  ViewController.swift
//  DecorateYourRoom
//
//  Created by Neil Mathew on 10/10/19.
//  Copyright © 2019 Placenote. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import PlacenoteSDK

class ViewController: UIViewController, ARSCNViewDelegate, ARSessionDelegate, PNDelegate {

    // UI Elements
    @IBOutlet var sceneView: ARSCNView!
    
    // Placenote variables
    private var camManager: CameraManager? = nil       // to control the AR camera
    private var ptViz: FeaturePointVisualizer? = nil  // to visualize Placenote features
    
    // class that displays the reticle (little red dot)
    private var reticle: Reticle = Reticle()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // ARKit delegate setup
        sceneView.session.delegate = self
        
        // Placenote initialization setup
        
        // Set up this viqew controller as a delegate
        LibPlacenote.instance.multiDelegate += self
        
        //Set up placenote's camera manager
        if let camera: SCNNode = sceneView?.pointOfView {
            camManager = CameraManager(scene: sceneView.scene, cam: camera)
        }
        
        // Placenote feature visualization
        ptViz = FeaturePointVisualizer(inputScene: sceneView.scene);
        ptViz?.enableFeaturePoints()
    
        reticle = Reticle(arview: sceneView)
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal]
        sceneView.autoenablesDefaultLighting = true
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

    
    
    
    
    func onPose(_ outputPose: matrix_float4x4, _ arkitPose: matrix_float4x4) {
        
    }
    
    func onStatusChange(_ prevStatus: LibPlacenote.MappingStatus, _ currStatus: LibPlacenote.MappingStatus) {
        
    }
    
    func onLocalized() {
        
    }
    
    // send AR frame to placenote
    func session(_ session: ARSession, didUpdate: ARFrame) {
        LibPlacenote.instance.setFrame(frame: didUpdate)
        //reticle.updateReticle()
    }
    
    // MARK: - ARSCNViewDelegate
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
    

}
