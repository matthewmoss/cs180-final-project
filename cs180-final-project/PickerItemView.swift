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
    var customShader: String?
}

class PickerItemView: UIView {
    
    // MARK: - Variables
    
    static var availableModels = [
        PickerItem(file: "spot", name: "Cow (SceneKit Phong)", customShader: nil),
        PickerItem(file: "bob", name: "Duck (SceneKit Phong)", customShader: nil),
        PickerItem(file: "blub", name: "Fish (SceneKit Phong)", customShader: nil),
        PickerItem(file: "spot", name: "Cow (Textured Phong)", customShader: "textured"),
        PickerItem(file: "bob", name: "Duck (Textured Phong)", customShader: "textured"),
        PickerItem(file: "spot", name: "Cow (Raw Phong)", customShader: "phong"),
        PickerItem(file: "bob", name: "Duck (Raw Phong)", customShader: "phong"),
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
        guard let node = SCNNode.loadFromScene(sceneFile: item.file, customShader: item.customShader) else { return }
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
