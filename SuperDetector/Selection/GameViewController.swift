//
//  GameViewController.swift
//  Batman
//
//  Created by Arthur  on 8/1/17.
//  Copyright © 2017 Arthur . All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit



class GameViewController: UIViewController {

    var batcave:BatCaveSceen?
    var currentCharacter:CharacterInfo?
    
    var chacterDelegate:CharacterSelectable?
    
    @IBOutlet weak var characterBarItem: UIBarButtonItem!
    
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        // Load 'GameScene.sks' as a GKScene. This provides gameplay related content
        // including entities and graphs.
        if let scene = GKScene(fileNamed: "BatCave")  {
            
            // Get the SKScene from the loaded GKScene
            if let sceneNode = scene.rootNode as! BatCaveSceen? {
                
                sceneNode.scaleMode = .resizeFill
                    
                sceneNode.characterDelegate = self
                // Copy gameplay related content over to the scene
                sceneNode.entities = scene.entities
                sceneNode.graphs = scene.graphs
                
                
                // Present the scene
                if let view = self.view as! SKView? {
                    view.presentScene(sceneNode)
                    
                    view.ignoresSiblingOrder = true
                    
                    view.showsFPS = true
                    view.showsNodeCount = true
                }
                
                
                batcave = sceneNode
                sceneNode.addItems()
                
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
  
        
         if !UIImagePickerController.isSourceTypeAvailable(.camera){
         self.navigationItem.rightBarButtonItem = nil
        }

    }
    @IBAction func shakeTap(_ sender: Any) {
        guard let bc = batcave else {return}
        bc.shake()
    }
    
    
  

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    /*
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? ViewController , let ch = self.currenÏtCharacter{
            vc.characterGen = ch.builder
        }
    }
 */
    

    
}

extension GameViewController : CharacterSelectable {
    func changeCharacter(_ info:CharacterInfo){
        self.title = info.name
        self.currentCharacter = info
        if let d = chacterDelegate {
            d.changeCharacter(info)
        }
    }

}
