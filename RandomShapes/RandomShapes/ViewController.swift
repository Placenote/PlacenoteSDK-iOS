//
//  ViewController.swift
//  Shape Dropper (Placenote SDK iOS Sample)
//
//  Created by Neil Mathew on 10/10/19.
//  Copyright © 2019 Placenote. All rights reserved.
//

import UIKit
import CoreLocation
import SceneKit
import ARKit
import PlacenoteSDK

class ViewController: UIViewController, ARSCNViewDelegate, ARSessionDelegate, UITableViewDelegate, UITableViewDataSource, PNDelegate, CLLocationManagerDelegate {
  

  //UI Elements
  @IBOutlet var sceneView: ARSCNView!
  
  //UI Elements
  @IBOutlet var mapTable: UITableView!
  @IBOutlet var thumbnailView: UIImageView!
  @IBOutlet var statusLabel: UILabel!
  @IBOutlet var tapGestureRecognizer: UITapGestureRecognizer!
  @IBOutlet weak var initView: UIView!
  @IBOutlet weak var mappingView: UIView!
  @IBOutlet weak var loadingView: UIView!
  @IBOutlet weak var mapListView: UIView!
  @IBOutlet weak var exitSessionButton: UIButton!
  

  private var trackingStarted: Bool = false;
  
  private var shapeManager: ShapeManager!

  //Variables to manage PlacenoteSDK features and helpers
  private var camManager: CameraManager? = nil;
  private var ptViz: FeaturePointVisualizer? = nil;
  private var thumbnailSelector: LocalizationThumbnailSelector? = nil;
  
  private var maps: [(String, LibPlacenote.MapMetadata)] = [("Sample Map", LibPlacenote.MapMetadata())]

  private var showFeatures: Bool = true
  private var locationManager: CLLocationManager!
  private var lastLocation: CLLocation? = nil
  
  
  private var thumbnailHandler: Disposable? = nil
  
  func thumbnailHandler(thumbnail: UIImage?) {
    thumbnailView.image = thumbnail
  }
  
  //Setup view once loaded
  override func viewDidLoad() {
    super.viewDidLoad()
    
    sceneView.delegate = self
    sceneView.session.delegate = self

    LibPlacenote.instance.multiDelegate += self
    
    //Set up placenote's camera manager
    if let camera: SCNNode = sceneView?.pointOfView {
      camManager = CameraManager(scene: sceneView.scene, cam: camera)
    }
    
    // Placenote feature visualization
    ptViz = FeaturePointVisualizer(inputScene: sceneView.scene)
    ptViz?.enablePointcloud()
    
    // A class that select an localization thumbnail for a map
    thumbnailSelector = LocalizationThumbnailSelector()
    thumbnailHandler = thumbnailSelector?.onNewThumbnail.addHandler(target: self,
        handler: ViewController.thumbnailHandler)
    thumbnailView.layer.borderColor = UIColor.white.cgColor

    //App Related initializations
    shapeManager = ShapeManager(view: sceneView)
    
    //Initialize tableview for the list of maps
    mapTable.delegate = self
    mapTable.dataSource = self
    mapTable.allowsSelection = true
    mapTable.isUserInteractionEnabled = true
    mapTable.register(UITableViewCell.self, forCellReuseIdentifier: "cell")

    //UI Updates
    locationManager = CLLocationManager()
    locationManager.requestWhenInUseAuthorization()

    if CLLocationManager.locationServicesEnabled() {
      locationManager.delegate = self;
      locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
      locationManager.startUpdatingLocation()
    }
  }

  //Initialize view and scene
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
    
    // remove thumbnail event handler
    if (thumbnailHandler != nil) {
      thumbnailHandler!.dispose()
    }
  }


  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    sceneView.frame = view.bounds
  }


  // MARK: - PNDelegate functions

  //Receive a pose update when a new pose is calculated
  func onPose(_ outputPose: matrix_float4x4, _ arkitPose: matrix_float4x4) -> Void {

  }
  
  // Callback to subscribe to the first localization event for loading assets
  public func onLocalized() -> Void {
    print ("Just localized, drawing view")
    shapeManager.drawView(parent: sceneView.scene.rootNode) //just localized redraw the shapes
    statusLabel.text = "Map Found!"

  }

  //Receive a status update when the status changes
  func onStatusChange(_ prevStatus: LibPlacenote.MappingStatus, _ currStatus: LibPlacenote.MappingStatus) {
    if (prevStatus != LibPlacenote.MappingStatus.running && currStatus == LibPlacenote.MappingStatus.running) {
    }
    if (prevStatus == LibPlacenote.MappingStatus.running && currStatus != LibPlacenote.MappingStatus.lost) {
    }

  }

  //Receive list of maps after it is retrieved. This is only fired when fetchMapList is called (see updateMapTable())
  func onMapList(success: Bool, mapList: [String: LibPlacenote.MapMetadata]) -> Void {
    maps.removeAll()
    if (!success) {
      print ("failed to fetch map list")
      statusLabel.text = "Map List not retrieved"
      return
    }

    //Cycle through the maplist and create a database of all the maps (place.key) and its metadata (place.value)
    for place in mapList {
      maps.append((place.key, place.value))
    }

    statusLabel.text = "Click on a map on load it. Swipe left to delete it."
    self.mapTable.reloadData() //reads from maps array (see: tableView functions)
    self.mapTable.isHidden = false

    self.tapGestureRecognizer?.isEnabled = false
  }

  // MARK: - UI functions
  
  // Start creating a new map
  @IBAction func newMap(_ sender: Any) {
    
    if (!trackingStarted)
    {
      statusLabel.text = "ARKit Tracking Session is not ready yet. Try again"
    }
    
    if (!LibPlacenote.instance.initialized())
    {
      statusLabel.text = "Placenote is not initialized yet. Try again";
    }
    
    // Starting mapping sesion
    LibPlacenote.instance.startSession()
    statusLabel.text = "Mapping: Tap to add shapes!"
    tapGestureRecognizer?.isEnabled = true

    initView.isHidden = true
    mappingView.isHidden = false
    
  }
  
  // tap handler for adding shapes
    @IBAction func handleTap(_ sender: UITapGestureRecognizer) {
      let tapLocation = sender.location(in: sceneView)
      let hitTestResults = sceneView.hitTest(tapLocation, types: .featurePoint)
      if let result = hitTestResults.first {
        let pose = LibPlacenote.instance.processPose(pose: result.worldTransform)
        shapeManager.spawnRandomShape(position: pose.position())
      }
    }
  
  //save map
  @IBAction func saveMap(_ sender: Any) {

    statusLabel.text = "Saving Map"
    tapGestureRecognizer?.isEnabled = false
    mappingView.isHidden = true
    var savedMapName: String = ""
    
    LibPlacenote.instance.saveMap(
        savedCb: {(mapId: String?) -> Void in
          if (mapId != nil) {
            self.statusLabel.text = "Saved Id: " + mapId! //update UI
            LibPlacenote.instance.stopSession()
            
            let metadata = LibPlacenote.MapMetadataSettable()
            
            savedMapName = RandomName.Get()
            metadata.name = savedMapName
            
            self.statusLabel.text = "Saved Map: " + metadata.name! //update UI
            
            if (self.lastLocation != nil) {
              metadata.location = LibPlacenote.MapLocation()
              metadata.location!.latitude = self.lastLocation!.coordinate.latitude
              metadata.location!.longitude = self.lastLocation!.coordinate.longitude
              metadata.location!.altitude = self.lastLocation!.altitude
            }
            var userdata: [String:Any] = [:]
            userdata["shapeArray"] = self.shapeManager.getShapeArray()
            metadata.userdata = userdata
            
            if (!LibPlacenote.instance.setMetadata(mapId: mapId!, metadata: metadata, metadataSavedCb: {(success: Bool) -> Void in})) {
              print ("Failed to set map metadata")
            }
          } else {
            NSLog("Failed to save map")
          }
        },
        uploadProgressCb: {(completed: Bool, faulted: Bool, percentage: Float) -> Void in
          if (completed) {
            self.statusLabel.text = "Uploaded Map: " + savedMapName
            self.initView.isHidden = false
            self.shapeManager.clearShapes()
            
          } else if (faulted) {
            print ("Couldnt upload map")
          } else {
            print ("Progress: " + percentage.description)
            self.statusLabel.text = "Map Upload: " + String(format: "%.3f", percentage) + "/1.0"
            
          }
        }
    )
  }
  
  // click load map to choose from a list of maps
  @IBAction func pickMap(_ sender: Any) {
    updateMapTable()
    statusLabel.text = "Fetching Map List"
    
    initView.isHidden = true
    mapListView.isHidden = false
  }

  
  @IBAction func cancelMapList(_ sender: Any) {
    mapListView.isHidden = true
    initView.isHidden = false
    statusLabel.text = "Map List Cancelled"
  }
    
  @IBAction func exitLoadingSession(_ sender: Any) {
    shapeManager.clearShapes()
    ptViz?.clearPointCloud()
    LibPlacenote.instance.stopSession()
    statusLabel.text = "Ended Session. To start again, click New Map or Load Map"
    
    initView.isHidden = false
    loadingView.isHidden = true
  }
  
  // MARK: - UITableViewDelegate and UITableviewDataSource to manage retrieving, viewing, deleting and selecting maps on a TableView

  //Return count of maps
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    print(String(format: "Map size: %d", maps.count))
    return maps.count
  }

  //Label Map rows
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let map = self.maps[indexPath.row]
    var cell:UITableViewCell? = mapTable.dequeueReusableCell(withIdentifier: map.0)
    if cell==nil {
      cell =  UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: map.0)
    }
    cell?.textLabel?.text = map.0

    let name = map.1.name
    if name != nil && !name!.isEmpty {
        cell?.textLabel?.text = name
    }

    var subtitle = "Distance Unknown"

    let location = map.1.location

    if (lastLocation == nil) {
        subtitle = "User location unknown"
    } else if (location == nil) {
        subtitle = "Map location unknown"
    } else {
        let distance = lastLocation!.distance(from: CLLocation(
            latitude: location!.latitude,
            longitude: location!.longitude))
        subtitle = String(format: "Distance: %0.3fkm", distance / 1000)
    }

    cell?.detailTextLabel?.text = subtitle

    return cell!
  }

  // Map selected. This directly starts loading the selected map
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    print(String(format: "Retrieving row: %d", indexPath.row))
    let mapId: String = maps[indexPath.row].0
    print("Retrieving mapId: " + mapId)
    statusLabel.text = "Retrieving mapId: " + mapId

    LibPlacenote.instance.loadMap(mapId: mapId,
      downloadProgressCb: {(completed: Bool, faulted: Bool, percentage: Float) -> Void in
        if (completed) {
          //self.mappingStarted = false //extending the map

          self.mapTable.isHidden = true

          //Use metadata acquired from fetchMapList
          let userdata = self.maps[indexPath.row].1.userdata as? [String:Any]
          if (self.shapeManager.loadShapeArray(shapeArray: userdata?["shapeArray"] as? [[String: [String: String]]])) {
            self.statusLabel.text = "Map Loaded. Point at the area in the thumbnail to localize"
          } else {
            self.statusLabel.text = "Map Loaded. Shape file not found"
          }
          LibPlacenote.instance.startSession()
          
          self.mapListView.isHidden = true
          
          self.loadingView.isHidden = false
          
          self.tapGestureRecognizer?.isEnabled = false
          
        } else if (faulted) {
          print ("Couldnt load map: " + mapId)
          self.statusLabel.text = "Load error Map Id: " + mapId
        } else {
          print ("Progress: " + percentage.description)
        }
      }
    )
  }

  //Make rows editable for deletion
  func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    return true
  }

  //Delete Row and its corresponding map
  func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
    if (editingStyle == UITableViewCellEditingStyle.delete) {
      statusLabel.text = "Deleting Map:" + maps[indexPath.row].0
      LibPlacenote.instance.deleteMap(mapId: maps[indexPath.row].0, deletedCb: {(deleted: Bool) -> Void in
        if (deleted) {
          print("Deleting: " + self.maps[indexPath.row].0)
          self.statusLabel.text = "Deleted Map: " + self.maps[indexPath.row].0
          self.maps.remove(at: indexPath.row)
          self.mapTable.reloadData()
        }
        else {
          print ("Can't Delete: " + self.maps[indexPath.row].0)
          self.statusLabel.text = "Can't Delete: " + self.maps[indexPath.row].0
        }
      })
    }
  }
  
  // get list of all maps
  func updateMapTable() {
    LibPlacenote.instance.listMaps(listCb: onMapList)
  }
  
  // search via gps location and radius
  func updateMapTable(radius: Float) {
    LibPlacenote.instance.searchMaps(latitude: self.lastLocation!.coordinate.latitude, longitude: self.lastLocation!.coordinate.longitude, radius: Double(radius), listCb: onMapList)
  }
  
  // search via name
  func updateMapTable(nameStr: String) {
    LibPlacenote.instance.searchMaps(name: nameStr, listCb: onMapList)
    
  }


  // MARK: - ARSCNViewDelegate

  // Override to create and configure nodes for anchors added to the view's session.
//  func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
//    let node = SCNNode()
//    return node
//  }


  // MARK: - ARSessionDelegate

  //Provides a newly captured camera image and accompanying AR information to the delegate.
  func session(_ session: ARSession, didUpdate: ARFrame) {
    LibPlacenote.instance.setARFrame(frame: didUpdate)
  }


  //Informs the delegate of changes to the quality of ARKit's device position tracking.
  func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
    var status = "Loading.."
    switch camera.trackingState {
    case ARCamera.TrackingState.notAvailable:
      status = "Not available"
    case ARCamera.TrackingState.limited(.excessiveMotion):
      status = "Excessive Motion."
    case ARCamera.TrackingState.limited(.insufficientFeatures):
      status = "Insufficient features"
    case ARCamera.TrackingState.limited(.initializing):
      status = "Initializing"
    case ARCamera.TrackingState.limited(.relocalizing):
      status = "Relocalizing"
    case ARCamera.TrackingState.normal:
      if (!trackingStarted) {
        trackingStarted = true
        print("ARKit Enabled, Start Mapping")
        
        // initPanel.isHidden = false

      }
      status = "Ready"
    }
    statusLabel.text = status
  }


  // MARK: - CLLocationManagerDelegate

  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    lastLocation = locations.last
  }
}
