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
  
  @IBOutlet weak var initPanelView: UIView!
  @IBOutlet weak var mappingPanelView: UIView!
  @IBOutlet weak var loadingPanelView: UIView!
  @IBOutlet weak var saveButton: UIButton!
  
  @IBOutlet weak var statusLabel: UILabel!
  
  
  // Placenote variables
  private var camManager: CameraManager? = nil       // to control the AR camera
  private var ptViz: FeaturePointVisualizer? = nil  // to visualize Placenote features
  private var thumbnailSelector: LocalizationThumbnailSelector? = nil;
  
  // class that displays the reticle (little red dot)
  private var reticle: Reticle = Reticle()
  private var showReticle: Bool = false
  
  // Declare the model manager
  private var modelManager: ModelManager = ModelManager()
  
  private var loadedMetaData: LibPlacenote.MapMetadata = LibPlacenote.MapMetadata()
  
  // Launch functions
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Set the view's delegate
    sceneView.delegate = self
    
    // Show statistics such as fps and timing information
    sceneView.showsStatistics = true
    
    // ARKit delegate setup
    sceneView.session.delegate = self
    
    // Placenote initialization setup
    LibPlacenote.instance.multiDelegate += self
    
    //Set up placenote's camera manager
    if let camera: SCNNode = sceneView?.pointOfView {
      camManager = CameraManager(scene: sceneView.scene, cam: camera)
    }
    
    // Placenote feature visualization
    ptViz = FeaturePointVisualizer(inputScene: sceneView.scene);
    ptViz?.enableFeaturePoints()
    
    // A class that select an localization thumbnail for a map
    thumbnailSelector = LocalizationThumbnailSelector()
    
    // initialize the reticle
    reticle = Reticle(arview: sceneView)
    
    // initialize the model manager
    modelManager.setScene(view: sceneView)
    
    statusLabel.text = "Click New Map to start a new session or Load Map to load a previous one"
  }
  
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    // arkit initialization
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
  
  // Button activated functions
  
  // start mapping
  @IBAction func startNewMap(_ sender: Any) {
    
    if (!LibPlacenote.instance.initialized()) {
      print("Placenote not initialized yet. Try again.")
    }
    
    statusLabel.text = "Use the red circle as a guide to place virtual objects around you"
    
    // ui navigation
    initPanelView.isHidden = true
    mappingPanelView.isHidden = false
    
    // start placenote mapping
    LibPlacenote.instance.startSession()
    
    reticle.activateReticle()
  }
  
  // Functions to add models to the scene
  
  @IBAction func addChair(_ sender: Any) {
    
    print (String (describing: reticle.getReticlePosition()))
    modelManager.addModelAtPose(pos: reticle.getReticlePosition(),
                                rot: reticle.getReticleRotation() ,index: 0)
  }
  
  @IBAction func addPlant(_ sender: Any) {
    
    print (String (describing: reticle.getReticlePosition()))
    modelManager.addModelAtPose(pos: reticle.getReticlePosition(),
                                rot: reticle.getReticleRotation() , index: 1)
  }
  
  @IBAction func addLamp(_ sender: Any) {
    modelManager.addModelAtPose(pos: reticle.getReticlePosition(),
                                rot: reticle.getReticleRotation(), index: 2)
  }
  
  @IBAction func addGramophone(_ sender: Any) {
    modelManager.addModelAtPose(pos: reticle.getReticlePosition(),
                                rot: reticle.getReticleRotation(), index: 3)
  }
  
  
  @IBAction func clearAllModels(_ sender: Any) {
    modelManager.clearModels()
  }
  
  @IBAction func saveMap(_ sender: Any) {
    
    mappingPanelView.isHidden = true
    reticle.deactivateReticle()
    
    LibPlacenote.instance.saveMap(
        savedCb: {(mapId: String?) -> Void in
          if (mapId != nil) {
            self.statusLabel.text = "Saved Id: " + mapId! //update UI
            
            LibPlacenote.instance.stopSession()
            
            // save the map id user defaults
            UserDefaults.standard.set(mapId, forKey: "mapId")
            
            let metadata = LibPlacenote.MapMetadataSettable()
            metadata.name = "Room Map"
            
            var userdata: [String:Any] = [:]
            userdata["modelArray"] = self.modelManager.getModelInfoJSON()
            metadata.userdata = userdata
            
            if (!LibPlacenote.instance.setMapMetadata(mapId: mapId!, metadata: metadata, metadataSavedCb: {(success: Bool) -> Void in})) {
              print ("Failed to set map metadata")
            }
          } else {
            NSLog("Failed to save map")
          }
        },
        uploadProgressCb: {(completed: Bool, faulted: Bool, percentage: Float) -> Void in
          if (completed) {
            print ("Uploaded!")
            self.statusLabel.text = "Upload completed. You can now load the map"
            self.initPanelView.isHidden = false
            self.modelManager.clearModels()
            
          } else if (faulted) {
            self.statusLabel.text = "Couldnt upload map"
          } else {
            print ("Progress: " + percentage.description)
            self.statusLabel.text = "Map Upload: " + String(format: "%.3f", percentage) + "/1.0"
          }
        }
    )
  }
  
  
  @IBAction func startLoadMap(_ sender: Any) {
    // get the saved map id
    let mapId = UserDefaults.standard.string(forKey: "mapId") ?? ""
    
    if (mapId == "")
    {
      self.statusLabel.text = "You have not saved a map yet. Nothing to load!"
      return
    }
    
    statusLabel.text = "Loading your saved map with ID: " + mapId
    ptViz?.disableFeaturePoints()
    
    LibPlacenote.instance.loadMap(mapId: mapId,
        downloadProgressCb: {(completed: Bool, faulted: Bool, percentage: Float) -> Void in
          if (completed) {
            
            // start the Placenote session (this will start searching for localization)
            LibPlacenote.instance.startSession()
            LibPlacenote.instance.getMapMetadata(mapId: mapId, getMetadataCb: { (success: Bool, metadata: LibPlacenote.MapMetadata) -> Void in
              if (success)
              {
                print(" Meta data was downloaded : " + metadata.name!)
                self.statusLabel.text = "Map and data are loaded. Point at your mapped area to relocalize"
                
                // storing meta data here so we can load it in the OnLocalized callback
                self.loadedMetaData = metadata
              }
            })
          } else if (faulted) {
            print ("Couldnt load map: " + mapId)
            self.statusLabel.text = "Load error Map Id: " + mapId
          } else {
            print ("Progress: " + percentage.description)
            self.statusLabel.text = "Downloading map: " + percentage.description
          }
        }
    )
    
  }
  
  // Placenote delegate functions
  
  func onPose(_ outputPose: matrix_float4x4, _ arkitPose: matrix_float4x4) {
    
  }
  
  func onStatusChange(_ prevStatus: LibPlacenote.MappingStatus, _ currStatus: LibPlacenote.MappingStatus) {
  }
  
  func onLocalized() {
    statusLabel.text = "Localized."
    
    // load the metadata objects into the scene
    let userdata = loadedMetaData.userdata as? [String:Any]
    
    if (self.modelManager.loadModelArray(modelArray: userdata?["modelArray"] as? [[String: [String: String]]])) {
      self.statusLabel.text = "Map Loaded. Look Around"
    } else {
      self.statusLabel.text = "Map Loaded. Shape file not found"
    }
  }
  
  // send AR frame to placenote
  func session(_ session: ARSession, didUpdate: ARFrame) {
    // send a frame to placenote
    LibPlacenote.instance.setARFrame(frame: didUpdate)
    
    // update the reticle per frame. Only runs it the reticle is active
    // see reticle.swift script to understand how the reticle works
    reticle.updateReticle()
  }
  
  
  // MARK: - ARSCNViewDelegate
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
