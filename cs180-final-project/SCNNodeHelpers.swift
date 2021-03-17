//
//  SCNNodeHelpers.swift
//  cs180-final-project
//
//  Created by Matt Moss on 3/17/21.
//

import Foundation
import SceneKit

extension SCNNode {
    
    static func loadFromScene(sceneFile: String, customShader: String?) -> SCNNode? {
        
        // Load model
        guard let scene = SCNScene(named: "art.scnassets/\(sceneFile).scn") else { print("couldn't find file"); return nil }
        guard let node = scene.rootNode.childNode(withName: sceneFile, recursively: true) else { print("couldn't find node"); return nil }
        
        if let custom = customShader {
        
            // Run custom shader
            // https://medium.com/@MalikAlayli/metal-with-scenekit-create-your-first-shader-2c4e4e983300
            let program = SCNProgram()
            program.vertexFunctionName = "\(custom)TextureVertex"
            program.fragmentFunctionName = "\(custom)TextureFragment"
            node.geometry?.firstMaterial?.program = program
            
            guard let textureImage = UIImage(named: "art.scnassets/\(sceneFile)_texture.png") else { print("no texture"); return nil }
            let materialProperty = SCNMaterialProperty(contents: textureImage)
            node.geometry?.firstMaterial?.setValue(materialProperty, forKey: "textureImage")
            
        }
        
        return node
        
    }
    
}

