//
//  ViewController.swift
//  cs180-final-project
//
//  Created by Matt Moss on 3/15/21.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    // MARK: - Config Constants
    
    let planeName = "plane"
    let buttonSpacing: CGFloat = 16
    
    // MARK: - Scene View Variables
    
    @IBOutlet var sceneView: ARSCNView!
    
    // MARK: - Coaching Variables
    
    internal var coachView: ARCoachingOverlayView!
    
    // MARK: - Control Variables
    
    internal var controlsView: UIView!
    internal var resetButton: UIButton!
    internal var placeObjectButton: UIButton!
    internal var takePictureButton: UIButton!
    
    // MARK: - Picker Variables
    
    internal var pickerTintView: UIView!
    internal var pickerView: UIView!
    internal var pickerPageControl: UIPageControl!
    internal var pickButton: UIButton!
    internal var pickerScrollView: UIScrollView!
    
    internal var placeObjectLabel: UILabel!
    
    internal var currentPickerItem: PickerItem?
    
    // MARK: - Pan Variables
    
    internal var panNode: SCNNode?
    internal var initialPanNodeRotation: Float = 0
    
    internal var pinchNode: SCNNode?
    internal var initialPinchNodeScale: Float = 0
    internal let pinchScaleFactor: Float = 0.1
    
    // MARK: - Camera Variables
    
    internal var cameraFlashView: UIView!
    
    // MARK: - UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.autoenablesDefaultLighting = true
        sceneView.automaticallyUpdatesLighting = true
        
        // Add tap gesture to scene
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(sceneWasTapped(_:)))
        sceneView.addGestureRecognizer(tapGesture)
        
        // Add pan gesture
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(sceneWasPanned(_:)))
        sceneView.addGestureRecognizer(panGesture)
        
        // Add pinch gesture
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(sceneWasPinched(_:)))
        sceneView.addGestureRecognizer(pinchGesture)
        
        // Add coach view
        coachView = ARCoachingOverlayView(frame: view.bounds)
        coachView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        // coachView.session = sceneView.session
        coachView.delegate = self
        view.addSubview(coachView)
        
        // Add camera flash view
        cameraFlashView = UIView(frame: view.bounds)
        cameraFlashView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        cameraFlashView.backgroundColor = UIColor.white.withAlphaComponent(0.8)
        cameraFlashView.alpha = 0.0
        view.addSubview(cameraFlashView)
        
        // Add picker tint view
        
        pickerTintView = UIView(frame: view.bounds)
        pickerTintView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        pickerTintView.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        pickerTintView.alpha = 0
        view.addSubview(pickerTintView)
        
        let tintTapGesture = UITapGestureRecognizer(target: self, action: #selector(pickerTintWasTapped(_:)))
        pickerTintView.addGestureRecognizer(tintTapGesture)
        
        // Add controls
        
        controlsView = UIView(frame: CGRect(x: buttonSpacing, y: view.bounds.height - 100, width: view.bounds.width - buttonSpacing * 2, height: 50))
        controlsView.autoresizingMask = [.flexibleWidth, .flexibleTopMargin]
        view.addSubview(controlsView)
        
        let buttonSymbolConfig = UIImage.SymbolConfiguration(pointSize: 27, weight: .regular, scale: .small)
        
        let resetIcon = UIImage(systemName: "arrow.clockwise", withConfiguration: buttonSymbolConfig)
        resetButton = UIButton(frame: CGRect(x: 0, y: 0, width: controlsView.bounds.height, height: controlsView.bounds.height))
        resetButton.layer.cornerRadius = resetButton.bounds.midY
        resetButton.backgroundColor = UIColor.white
        resetButton.setImage(resetIcon, for: .normal)
        resetButton.imageView?.tintColor = UIColor.black
        resetButton.addTarget(self, action: #selector(resetSelected(_:)), for: .touchUpInside)
        controlsView.addSubview(resetButton)
        
        placeObjectButton = UIButton(frame: CGRect(x: resetButton.frame.maxX + buttonSpacing, y: 0, width: controlsView.bounds.width - buttonSpacing * 2 - controlsView.bounds.height * 2, height: controlsView.bounds.height))
        placeObjectButton.layer.cornerRadius = resetButton.bounds.midY
        placeObjectButton.backgroundColor = UIColor.white
        placeObjectButton.setTitleColor(UIColor.black, for: .normal)
        placeObjectButton.setTitleColor(UIColor.black.withAlphaComponent(0.7), for: .highlighted)
        placeObjectButton.setTitle("Place New Object", for: .normal)
        placeObjectButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        placeObjectButton.addTarget(self, action: #selector(placeObjectSelected(_:)), for: .touchUpInside)
        controlsView.addSubview(placeObjectButton)
        
        let cameraIcon = UIImage(systemName: "camera", withConfiguration: buttonSymbolConfig)
        takePictureButton = UIButton(frame: CGRect(x: placeObjectButton.frame.maxX + buttonSpacing, y: 0, width: controlsView.bounds.height, height: controlsView.bounds.height))
        takePictureButton.layer.cornerRadius = resetButton.bounds.midY
        takePictureButton.backgroundColor = UIColor.white
        takePictureButton.setImage(cameraIcon, for: .normal)
        takePictureButton.imageView?.tintColor = UIColor.black
        takePictureButton.addTarget(self, action: #selector(takePictureButtonSelected(_:)), for: .touchUpInside)
        controlsView.addSubview(takePictureButton)
        
        // Add place object label
        
        placeObjectLabel = UILabel(frame: CGRect(x: 0, y: view.bounds.height - 150, width: view.bounds.width, height: 100))
        placeObjectLabel.numberOfLines = 0
        placeObjectLabel.text = "Tap anywhere to\nplace the object"
        placeObjectLabel.textColor = UIColor.white
        placeObjectLabel.textAlignment = .center
        placeObjectLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        placeObjectLabel.layer.shadowColor = UIColor.black.cgColor
        placeObjectLabel.layer.shadowOffset = CGSize(width: 0, height: 2)
        placeObjectLabel.layer.shadowRadius = 10
        placeObjectLabel.layer.shadowOpacity = 0.2
        placeObjectLabel.alpha = 0.0
        view.addSubview(placeObjectLabel)
        
        // Add picker
        
        pickerView = UIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 500))
        pickerView.layer.cornerRadius = 28
        pickerView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        pickerView.backgroundColor = UIColor.white
        view.addSubview(pickerView)
        
        pickerScrollView = UIScrollView(frame: pickerView.bounds)
        pickerScrollView.showsHorizontalScrollIndicator = false
        pickerScrollView.contentSize = CGSize(width: pickerScrollView.bounds.width * CGFloat(PickerItemView.availableModels.count), height: pickerScrollView.bounds.height)
        pickerScrollView.isPagingEnabled = true
        pickerScrollView.delegate = self
        pickerView.addSubview(pickerScrollView)
        
        var xOffset: CGFloat = 0
        for item in PickerItemView.availableModels {
            let pickerItemView = PickerItemView(frame: pickerScrollView.bounds, item: item)
            pickerItemView.frame.origin.x = xOffset
            pickerScrollView.addSubview(pickerItemView)
            xOffset += pickerView.bounds.width
        }
        
        pickButton = UIButton(frame: CGRect(x: buttonSpacing, y: pickerView.bounds.height - 100, width: pickerView.bounds.width - buttonSpacing * 2, height: 50))
        pickButton.backgroundColor = UIColor.black.withAlphaComponent(0.1)
        pickButton.setTitle("Start Placing Object", for: .normal)
        pickButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        pickButton.setTitleColor(UIColor.black.withAlphaComponent(0.8), for: .normal)
        pickButton.setTitleColor(UIColor.black.withAlphaComponent(0.5), for: .highlighted)
        pickButton.layer.cornerRadius = 10
        pickButton.addTarget(self, action: #selector(pickSelected(_:)), for: .touchUpInside)
        pickerView.addSubview(pickButton)
        
        pickerPageControl = UIPageControl(frame: CGRect(x: 0, y: pickButton.frame.origin.y - 50, width: pickerView.bounds.width, height: 50))
        pickerPageControl.numberOfPages = PickerItemView.availableModels.count
        pickerPageControl.pageIndicatorTintColor = UIColor.black.withAlphaComponent(0.2)
        pickerPageControl.currentPageIndicatorTintColor = UIColor.black.withAlphaComponent(0.5)
        pickerView.addSubview(pickerPageControl)
        
        // Hide picker by default
        setObjectPickerHidden(true, animated: false)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        restartSession()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
        
    }
    
    // MARK: - Tap events
    
    @objc func sceneWasTapped(_ gesture: UIGestureRecognizer) {
        
        // Get picker item
        guard let item = currentPickerItem else { return }
        
        // Get touch location in view
        let location = gesture.location(in: sceneView)
        
        // Perform a hit test within the scene to determine if a surface is visible
        guard let query = sceneView.raycastQuery(from: location, allowing: .estimatedPlane, alignment: .horizontal) else { return }
        let results = sceneView.session.raycast(query)
        for result in results {
            
            // Get hit test location
            let resultLocation = SCNVector3(result.worldTransform.columns.3.x, result.worldTransform.columns.3.y, result.worldTransform.columns.3.z)
            
            // Load model
            guard let node = SCNNode.loadFromScene(sceneFile: item.file, customShader: item.customShader) else { continue }
            
            // Add to scene
            node.worldPosition = SCNVector3(node.worldPosition.x + resultLocation.x, node.worldPosition.y + resultLocation.y, node.worldPosition.z + resultLocation.z)
            node.pivot = SCNMatrix4MakeTranslation(0, -0.5, 0) // center on bottom of object
            sceneView.scene.rootNode.addChildNode(node)
            
            // Hide label
            UIView.animate(withDuration: 0.2) {
                self.placeObjectLabel.alpha = 0.0
            } completion: { (completed) in
                UIView.animate(withDuration: 0.2) {
                    self.controlsView.alpha = 1.0
                }
            }
            
            // Stoop picking
            currentPickerItem = nil

            // Only place once and don't reach the error
            return
            
        }
        
        // Show error otherwise
        let alert = UIAlertController(title: "No Plane Detected", message: "Try moving your phone around more so that ARKit can get a grasp on the scene.", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
        
    }
    
    // MARK: - Pan + Pinch Events
    
    @objc func sceneWasPinched(_ gesture: UIPinchGestureRecognizer) {
        
        // Check that the user isn't planing an object
        guard currentPickerItem == nil else { return }
        
        if gesture.state == .began {
            
            // Get location in view
            let location = gesture.location(in: sceneView)
            
            // Find node at point and remember
            let hitTestResults = sceneView.hitTest(location, options: nil)
            for result in hitTestResults {
                
                // Get node
                guard let name = result.node.name else { continue }
                print("began rotating node: \(name)")
                
                // Remember
                self.pinchNode = result.node
                self.initialPinchNodeScale = result.node.scale.x
                
            }
            
        } else if gesture.state == .changed {
            
            // Get node
            guard let node = pinchNode else { return }
            
            // Update rotation
            let newScale = initialPinchNodeScale * Float(gesture.scale)
            node.scale = SCNVector3(newScale, newScale, newScale)
            
        } else if gesture.state == .ended || gesture.state == .cancelled || gesture.state == .failed {
            pinchNode = nil
        }
        
    }
    
    @objc func sceneWasPanned(_ gesture: UIPanGestureRecognizer) {
        
        // Check that the user isn't planing an object
        guard currentPickerItem == nil else { return }
        
        if gesture.state == .began {
            
            // Get location in view
            let location = gesture.location(in: sceneView)
            
            // Find node at point and remember
            let hitTestResults = sceneView.hitTest(location, options: nil)
            for result in hitTestResults {
                
                // Get node
                guard let name = result.node.name else { continue }
                print("began rotating node: \(name)")
                
                // Remember
                self.panNode = result.node
                self.initialPanNodeRotation = result.node.eulerAngles.y
                
            }
            
        } else if gesture.state == .changed {
            
            // Get node
            guard let node = panNode else { return }
            
            // Update rotation
            let translation = gesture.translation(in: sceneView)
            let additonalRotation = Float(translation.x) * Float.pi / 180
            node.eulerAngles.y = initialPanNodeRotation + additonalRotation
            
        } else if gesture.state == .ended || gesture.state == .cancelled || gesture.state == .failed {
            panNode = nil
        }
        
    }
    
    // MARK: - Reset
    
    @objc func resetSelected(_ sender: AnyObject) {
        let alert = UIAlertController(title: "Restart AR Session?", message: "This will remove objects you've placed.", preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        
        let restartAction = UIAlertAction(title: "Restart", style: .destructive) { (action) in
            self.restartSession()
        }
        alert.addAction(restartAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Object Picker
    
    @objc func placeObjectSelected(_ sender: AnyObject) {
        setObjectPickerHidden(false, animated: true)
    }
    
    func setObjectPickerHidden(_ isHidden: Bool, animated: Bool) {
        if animated {
            if isHidden {

                UIView.animate(withDuration: 0.3, delay: 0.05, options: [], animations: {
                    self.pickerTintView.alpha = 0.0
                }, completion: nil)

                
                UIView.animate(withDuration: 0.48, delay: 0.0, usingSpringWithDamping: 0.82, initialSpringVelocity: 0.0, options: [], animations: {
                    self.pickerView.frame.origin.y = self.view.bounds.height
                }, completion: nil)

                
            } else {
                
                UIView.animate(withDuration: 0.3) {
                    self.pickerTintView.alpha = 1.0
                }
                
                UIView.animate(withDuration: 0.48, delay: 0.0, usingSpringWithDamping: 0.82, initialSpringVelocity: 0.0, options: [], animations: {
                    self.pickerView.frame.origin.y = self.view.bounds.height - self.pickerView.bounds.height
                }, completion: nil)
                
            }
        } else {
            if isHidden {
                pickerTintView.alpha = 0.0
                pickerView.frame.origin.y = view.bounds.height
            } else {
                pickerTintView.alpha = 1.0
                pickerView.frame.origin.y = view.bounds.height - pickerView.bounds.height
            }
        }
    }
    
    @objc func pickerTintWasTapped(_ sender: UIGestureRecognizer) {
        setObjectPickerHidden(true, animated: true)
    }
    
    @objc func pickSelected(_ sender: AnyObject) {
        
        // Hide picker
        setObjectPickerHidden(true, animated: true)
        
        // Get item
        let item = PickerItemView.availableModels[pickerPageControl.currentPage]
        currentPickerItem = item
        
        // Hide controls
        placeObjectLabel.alpha = 1.0
        controlsView.alpha = 0.0
        
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
    
    // MARK: - Restart
    
    func restartSession() {
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal]
        
        // Remove children
        for child in sceneView.scene.rootNode.childNodes {
            child.removeFromParentNode()
        }

        // Run the view's session
        sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors, .resetSceneReconstruction])
        
    }
    
    // MARK: - Picture Capture
    
    @objc func takePictureButtonSelected(_ sender: AnyObject) {
        
        // Run flash animation
        cameraFlashView.alpha = 1.0
        UIView.animate(withDuration: 0.35, delay: 0.0, options: [.curveEaseOut], animations: {
            self.cameraFlashView.alpha = 0.0
        }, completion: nil)
        
        // Get image
        let image = sceneView.snapshot()
        
        // Present default iOS share sheet
        let activityViewController = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        present(activityViewController, animated: true, completion: nil)

    }
    
}

extension ViewController: ARCoachingOverlayViewDelegate {
    
    // MARK: - ARCoachingOverlayViewDelegate
    
    func coachingOverlayViewWillActivate(_ coachingOverlayView: ARCoachingOverlayView) {
        UIView.animate(withDuration: 0.2) {
            self.controlsView.alpha = 0.0
            self.placeObjectLabel.alpha = 0.0
        }
        setObjectPickerHidden(true, animated: true)
        currentPickerItem = nil
    }
    
    func coachingOverlayViewDidDeactivate(_ coachingOverlayView: ARCoachingOverlayView) {
        UIView.animate(withDuration: 0.2) {
            self.controlsView.alpha = 1.0
        }
    }
    
    func coachingOverlayViewDidRequestSessionReset(_ coachingOverlayView: ARCoachingOverlayView) {
        restartSession()
    }
    
}

extension ViewController: UIScrollViewDelegate {
    
    // MARK: - UIScrollViewDelegate
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let index = Int(round(scrollView.contentOffset.x / scrollView.bounds.width))
        pickerPageControl.currentPage = index
    }
    
}
