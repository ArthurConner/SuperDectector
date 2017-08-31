//
//  ViewController.swift
//  SuperDetector
//
//  Created by Arthur  on 8/3/17.
//  Copyright © 2017 Arthur . All rights reserved.
//

import UIKit
import SpriteKit
import ARKit

class HeroDetectorConroller: UIViewController {
    
    @IBOutlet var sceneView: ARSKView!
    
    var dimset = DimensionSetting()
    var anim:FacialAnimator?
    
    var nodeGenerator:CharacterBuilder = makeBatMan
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dimset.adjustScale(0.15, scaleY:015)
        
        // Set the view's delegate
        sceneView.delegate = self
        anim = FacialAnimator(settings:dimset)
        
        // Show statistics such as fps and node count
        sceneView.showsFPS = true
        sceneView.showsNodeCount = true
        
        // Load the SKScene from 'Scene.sks'
        if let scene = SKScene(fileNamed: "HeroDetectScene") {
            sceneView.presentScene(scene)
        }
    }
    
    func animateHero(_ node:SKNode){
        
        guard let an = self.anim else {return}
        
        let delta = 1 + Double(an.ygen.nextUniform() * 4)
        let delayTime = DispatchTime.now() + delta
        
        DispatchQueue.main.asyncAfter(deadline: delayTime) {[weak self, weak node] in
            guard let n = node, let s = self, let an = s.anim else {return}
            an.animateEyes(n)
            s.animateHero(n)
        }
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
    // MARK: - ARSKViewDelegate
    

    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? GameViewController {
            vc.chacterDelegate = self
        }
    }
}

extension HeroDetectorConroller:ARSKViewDelegate {
    func view(_ view: ARSKView, nodeFor anchor: ARAnchor) -> SKNode? {
        // Create and configure a node for the anchor added to the view's session.
        
        let heroNode = SKShapeNode(rect: CGRect(x: 0, y: 0, width: 20, height: 20))
        let _ = nodeGenerator(heroNode,  dimset)
        heroNode.setScale(0.20)
        animateHero(heroNode)
        
        return heroNode;
    }
}

extension HeroDetectorConroller:CharacterSelectable {
    func changeCharacter(_ info: CharacterInfo) {
        self.nodeGenerator = info.builder
    }
}
