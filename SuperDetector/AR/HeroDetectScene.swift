//
//  Scene.swift
//  SuperDetector
//
//  Created by Arthur  on 8/3/17.
//  Copyright © 2017 Arthur . All rights reserved.
//

import SpriteKit
import ARKit

class HeroDetectScene: SKScene {
    
    
    var dimset = DimensionSetting()
    var anim:FacialAnimator?
    
    
    override func sceneDidLoad() {
        
       
       // dimset.adjustScale(0.15, scaleY:015)
   
        self.anim = FacialAnimator(settings: dimset)
        // addItems()
        
    }

    override func didMove(to view: SKView) {
        // Setup your scene here
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let sceneView = self.view as? ARSKView else {
            return
        }
        if let touch = touches.first {
        let positionInScene = touch.location(in: self)
        let nodes =  self.nodes(at: positionInScene)
        
        
        if var node = nodes.first , let a = anim{
            
            while (node.name != "root" && node.parent != nil){
                node = node.parent!
            }
            
            if node.name == "root"{
            a.wink(node)
            print("going to close eyes on \(String(describing: node.name))")
            return
            }
        }
            
        }
        if let currentFrame = sceneView.session.currentFrame {
            
            // Create a transform with a translation of 0.2 meters in front of the camera
            var translation = matrix_identity_float4x4
            translation.columns.3.z = -0.2
            let transform = simd_mul(currentFrame.camera.transform, translation)
            
            // Add a new anchor to the session
            let anchor = ARAnchor(transform: transform)
            sceneView.session.add(anchor: anchor)
        }
    }
}
