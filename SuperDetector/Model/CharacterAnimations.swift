//
//  CharacterAnimations.swift
//  SuperDetector
//
//  Created by Arthur  on 8/4/17.
//  Copyright © 2017 Arthur . All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit



struct FacialAnimator {
    let settings:DimensionSetting
    let ygen = GKGaussianDistribution(lowestValue: 0, highestValue: 2  )
    let xgen = GKGaussianDistribution(lowestValue: -8, highestValue: 8   )
    
    
    func closeEyes(_ node: SKNode){
        
        let act = SKAction.group([SKAction.scaleX(by: 1.0, y: 0.2, duration:  0.2),SKAction.moveBy(x: 0, y: +2, duration: 0.2)])
        
        let back = act.reversed()
     
     
        
       
         guard let l = node.childNode(withName: "leftEye"),  let r = node.childNode(withName: "rightEye") else {
         return
         }
         
        
  
        
        guard let lp = node.childNode(withName: "leftPupil"),  let rp = node.childNode(withName: "rightPupil") else {
            return
        }
        
        for x in [l,lp,r,rp]{
            
            x.run(act, completion: {[weak x] in
                
                x?.run(back)
                
            })
            
        }
        
        
    }
    
    func wink(_ node: SKNode){
        
       
        
        guard let l = node.childNode(withName: "leftEye"),  let r = node.childNode(withName: "rightEye") else {
            return
        }
        
        
        
        
        guard let lp = node.childNode(withName: "leftPupil"),  let rp = node.childNode(withName: "rightPupil") else {
            return
        }
        
        let list:[SKNode]
        let rlist:[SKNode]
        
        if xgen.nextInt() > 0 {
            list = [l,lp]
            rlist = [r,rp]
        } else  {
            list = [r,rp]
            rlist =  [l,lp]
        }
        
        let act = SKAction.group([SKAction.scaleX(by: 1.0, y: 0.02, duration:  0.2),SKAction.moveBy(x: 0, y: +2, duration: 0.2)])
        
        let back = act.reversed()

        for x in list{
            
            x.run(act, completion: {[weak x] in
                x?.run(back)
            })
            
        }
        
        
        let act1 = SKAction.group([SKAction.scaleX(by: 0.95, y: 1.05, duration:  0.2),SKAction.moveBy(x: 0, y: -0.5, duration: 0.2)])
        
        let back1 = act1.reversed()
        
        for x in rlist{
            
            x.run(act1, completion: {[weak x] in
                x?.run(back1)
            })
            
        }
        
        
        
    }
    
    func movePup(_ node: SKNode){
        
        
        let amount = (CGFloat(xgen.nextUniform()*4),CGFloat(-ygen.nextUniform()/3),Double(ygen.nextUniform()/2)+0.1)
        
        let act = SKAction.group([SKAction.moveBy(x: amount.0 , y: amount.1, duration:amount.2)])
        
        let back = act.reversed()
        
        
        
        
        guard let l = node.childNode(withName: "leftPupil"),  let r = node.childNode(withName: "rightPupil") else {
            return
        }
        
        
        
        l.run(act, completion: {[weak l] in
            
            l?.run(back)
            
        })
        r.run(act, completion: {[weak r] in
            
            r?.run(back)
            
        })
        
        
    }
    
    func animateEyes(_ node: SKNode){
        
        if ygen.nextUniform() > 0.2 {
            closeEyes(node)
        } else {
            movePup(node)
        }

    }
    
        
         func grow(_ node: SKNode){
    
        
        let act = SKAction.scaleX(by: 1.8, y: 1.8, duration:  7)
        let back = act.reversed()
        
        node.run(act, completion: {[weak node] in
            
            node?.run(back)
            
        })
        

    }
 
    
}

