//
//  BatCaveSceen.swift
//  Batman
//
//  Created by Arthur  on 8/1/17.
//  Copyright © 2017 Arthur . All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit





extension CGFloat {
    static func random() -> CGFloat {
        return CGFloat(Float(arc4random()) / Float(UInt32.max))
    }
    static func random(min: CGFloat, max: CGFloat) -> CGFloat {
        assert(min < max)
        return CGFloat.random() * (max - min) + min
    }
}



class BatCaveSceen: SKScene, CharacterSelectable {
    
    var entities = [GKEntity]()
    var graphs = [String : GKGraph]()
    var characterDelegate: CharacterSelectable?
    private var lastUpdateTime : TimeInterval = 0
    
    
    
    
    func addCharacter(_ name:String,_ bu: @escaping CharacterBuilder,node:SKNode,xoffset:CGFloat,yoffset:CGFloat){
        
        guard let b = CharacterInfo(name,bu,node:node,settings:dimset,xoffset:xoffset,yoffset:yoffset) else { return }
        self.addChild(b.node)
        characters[name] = b
    }
    
    private var characters:[String:CharacterInfo] = [:]
    
    var currentNode:[UITouch:SKNode] = [:]
    var dimset = DimensionSetting()
    var facial:FacialAnimator?
    
    func shake(){
        if characters.isEmpty {
            
            addItems()
        }
        
        for (_ , character) in characters{
            if let pb = character.node.physicsBody {
                let change = CGFloat.random(min: 300, max: 600)
                
                pb.applyImpulse(
                    
                    
                    CGVector(dx: 450-change, dy: change*4)
                )
            }
        }
    }
    
    func addItems(){
        
        self.facial = FacialAnimator(settings: dimset)
        if let r = self.childNode(withName: "//Robin") as? SKShapeNode {
            
            let cast = CharacterSpec.makeCast()
            
            var xoff:CGFloat = 200
            var yoff:CGFloat = 200
            var changeItem = true
            
            for (name,builder) in cast {
                self.addCharacter(name, builder, node: r, xoffset: xoff, yoffset: yoff)
                if (changeItem){
                    xoff -= 50
                    yoff = -yoff/3*2
                } else {
                   // xoff -= xoff
                    yoff = -yoff
                }
                
                changeItem = !(changeItem)
                
            }

            self.removeChildren(in: [r])
 
        }
        
    
        
        
       
        
        self.physicsBody = SKPhysicsBody(edgeLoopFrom: self.frame)
       
        
    }
    override func sceneDidLoad() {
        
        self.lastUpdateTime = 0
        
      
        
        dimset.adjust(scaleX: 0.5, scaleY: 0.5, xOff: 50.0, yOff: 50.0)
       // addItems()50.0
  
    }
    
    
    func changeCharacter(_ info:CharacterInfo){
        if let d = self.characterDelegate {
            d.changeCharacter(info)
        }
    }
    
    func touchDown(atPoint pos : CGPoint) {
        guard let b =  characters["batman"] else { return }
        let path = CGMutablePath()
        path.move(to: b.node.position)
        path.addLine(to: pos)
        let act = SKAction.move(to: pos, duration: 1)
        // let act = SKAction.follow(path, asOffset:false, speed: 1)
        b.node.run(act)
        
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        
        currentNode.removeAll()
        
        
        
        
        for t in touches {
            
            for (name,character ) in characters {
                
                if character.node.contains(t.location(in:self)) {
                    print("\(name) touched")
                    currentNode[t] = character.node
                    changeCharacter(character)
                    
                    if let pb = character.node.physicsBody {
                        let change = CGFloat.random(min: 300, max: 600)
                        
                        if let face = self.facial{
                            face.grow(character.node)
                        }
                        pb.applyImpulse(
                            
                            
                            CGVector(dx: 450-change, dy: change*4)
                        )
                    }
                    
                }
                
            }
            
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        /*
         for t in touches {
         
         if let n = currentNode[t]{
         
         
         let path = CGMutablePath()
         path.move(to: n.position)
         path.addLine(to: t.location(in:self))
         let act = SKAction.move(to: t.location(in:self), duration: 1)
         // let act = SKAction.follow(path, asOffset:false, speed: 1)
         n.run(act)
         
         
         
         }
         
         }
         */
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        //for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        //for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        
        // Initialize _lastUpdateTime if it has not already been
        if (self.lastUpdateTime == 0) {
            self.lastUpdateTime = currentTime
        }
        
        // Calculate time since last update
        let dt = currentTime - self.lastUpdateTime
        
        // Update entities
        for entity in self.entities {
            entity.update(deltaTime: dt)
        }
        
        self.lastUpdateTime = currentTime
    }
    
    
}
