//
//  PickerItem.swift
//  cs180-final-project
//
//  Created by Matt Moss on 3/15/21.
//

import UIKit
import SceneKit

struct PickerItem {
    var file: String
    var name: String
}

class PickerItemView: UIView {
    
    // MARK: - Variables
    
    static var availableModels = [
        PickerItem(file: "spot", name: "Cow"),
        PickerItem(file: "bob", name: "Duck"),
        PickerItem(file: "blub", name: "Fish")
    ]
    
    var titleLabel: UILabel!
    var sceneView: SCNView!
    
    // MARK: - Init
    
    init(frame: CGRect, item: PickerItem) {
        
        // Add title
        titleLabel = UILabel(frame: CGRect(x: 0, y: 6, width: frame.size.width, height: 80))
        titleLabel.text = item.name
        titleLabel.textAlignment = .center
        titleLabel.textColor = UIColor.black.withAlphaComponent(0.6)
        titleLabel.font = UIFont.systemFont(ofSize: 28, weight: .medium)
        titleLabel.autoresizingMask = .flexibleWidth
        
        // Add scene
        let sceneHeight: CGFloat = 280
        sceneView = SCNView(frame: CGRect(x: 0, y: frame.size.height / 2 - sceneHeight / 2 - 44, width: frame.size.width, height: sceneHeight))
        sceneView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        sceneView.autoenablesDefaultLighting = true
        sceneView.scene = SCNScene()
        
        // Init
        super.init(frame: frame)
        
        // Add subviews
        addSubview(titleLabel)
        addSubview(sceneView)
        
        // Load model
        guard let scene = SCNScene(named: "art.scnassets/\(item.file).scn") else { print("couldn't find file"); return }
        guard let node = scene.rootNode.childNode(withName: item.file, recursively: true) else { print("couldn't find node"); return }
        sceneView.scene?.rootNode.addChildNode(node)
        
        // Start rotation animation
        let rotationAnimation = CABasicAnimation(keyPath: "rotation")
        rotationAnimation.duration = 5
        rotationAnimation.repeatCount = .infinity
        rotationAnimation.fromValue = NSValue(scnVector4: SCNVector4(x: 0, y: 1, z: 0, w: 0))
        rotationAnimation.toValue = NSValue(scnVector4: SCNVector4(x: 0, y: 1, z: 0, w: Float.pi * 2))
        node.addAnimation(rotationAnimation, forKey: "rotate")
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
