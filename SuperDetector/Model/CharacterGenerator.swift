//
//  CharacterGenerator.swift
//  Batman
//
//  Created by Arthur  on 8/3/17.
//  Copyright © 2017 Arthur . All rights reserved.
//

import Foundation
import SpriteKit

typealias PathMaker = ()->CGPath
typealias NodeMaker = ()->(String,UIColor,UIColor?,PathMaker)
typealias EarMaker = ()->(SKShapeNode,SKShapeNode)
typealias CharacterBuilder = (SKNode?,  DimensionSetting)->CharacterSpec

struct CharacterInfo{
    let builder:CharacterBuilder
    let name:String
    
    let node:SKShapeNode
    
    init?(_ name:String,_ bu:@escaping CharacterBuilder,node:SKNode,settings:DimensionSetting,xoffset:CGFloat,yoffset:CGFloat ){
        
        guard let c = node.copy() as? SKShapeNode else { return nil }
        
        c.position = CGPoint(x:c.position.x-xoffset,y:c.position.y-yoffset)
        self.node = c
        let _ = bu(c,settings)
        self.builder = bu
        
        self.name = name
        
    }
}

protocol CharacterSelectable {
    func changeCharacter(_ info:CharacterInfo);
}

struct CharacterSpec {
    let mask:UIColor
    
    var skin:UIColor = UIColor(red: 0.998, green: 0.895, blue: 0.855, alpha: 1.000)
    var skullColor:UIColor?
    var lips = UIColor(red: 0.800, green: 0.320, blue: 0.320, alpha: 1.000)
    var eyes:UIColor = .white
    var hair:UIColor?
    var hairStroke = UIColor.clear
    var earColor:UIColor?
    var earMaker:EarMaker?
    var nodeMakers:[NodeMaker] = []
    var headMaker:PathMaker
    var faceMaker:PathMaker?
    var settings: DimensionSetting
    
    init(mask:UIColor, settings:DimensionSetting){
        self.mask = mask
        self.settings = settings
        
        self.headMaker = {
            //let headPath = UIBezierPath(ovalIn: settings.batRect(x: 4, y: 6, width: 56, height: 68))
            //return headPath.cgPath
            return settings.makeHead()
        }
        
        self.faceMaker = {
            return settings.makeFace()
        }
    }
    
    func node(rootNode:SKNode){
        print("\n\nmaking node")
        let body =  SKPhysicsBody(circleOfRadius: 30)
        rootNode.physicsBody = body
        body.mass = 1
        
        let headNode = SKShapeNode(path: self.headMaker())
        headNode.fillColor = mask
        headNode.name = "head"
        headNode.strokeColor = .clear
        rootNode.addChild(headNode)
        
        let eyeHeight:CGFloat = 33
        
        if let f = self.faceMaker {
            let faceNode = SKShapeNode(path:f())
            faceNode.fillColor = skin
            faceNode.strokeColor = .clear
            faceNode.name = "face"
            headNode.addChild(faceNode)
            
            let mouthNode = SKShapeNode(path:settings.makeMouth(x: 18, y: 56))
            mouthNode.fillColor = lips
            mouthNode.strokeColor = lips
            mouthNode.name = "mouth"
            faceNode.addChild(mouthNode)
        }
        
        let leftEyeNode = SKShapeNode(path:settings.makeEye(x: 10, y: eyeHeight))
        leftEyeNode.fillColor = eyes
        leftEyeNode.name = "leftEye"
        rootNode.addChild(leftEyeNode)
        
        let rightEyeNode = SKShapeNode(path:settings.makeEye(x: 41, y: eyeHeight))
        rightEyeNode.fillColor = eyes
        rightEyeNode.name = "rightEye"
        rootNode.addChild(rightEyeNode)
        
        let leftPupil = SKShapeNode(path:settings.makePupil(x: 15, y: eyeHeight))
        leftPupil.fillColor = .black
        leftPupil.strokeColor = .black
        leftPupil.name = "leftPupil"
        rootNode.addChild(leftPupil)
        
        let rightPupil = SKShapeNode(path:settings.makePupil(x: 46, y: eyeHeight))
        rightPupil.fillColor = .black
        rightPupil.strokeColor = .black
        rightPupil.name = "rightPupil"
        rootNode.addChild(rightPupil)
        
        if let r = rootNode as? SKShapeNode {
            r.fillColor = .clear
            r.strokeColor = .clear
        }
        
        if let e = self.earMaker {
            let (leftEarNode,rightEarNode) = e()
            // let leftEarNode = SKShapeNode(path:makeEar(x:16,y:-0.5))
            leftEarNode.fillColor = earColor ?? mask
            leftEarNode.strokeColor = earColor ?? mask
            leftEarNode.name = "leftEar"
            rootNode.addChild(leftEarNode)
            
            //let rightEarNode = SKShapeNode(path:makeEar(x:47,y:-0.5))
            rightEarNode.fillColor = earColor ?? mask
            rightEarNode.name = "rightEar"
            rightEarNode.strokeColor = earColor ?? mask
            rootNode.addChild(rightEarNode)
        } else {
            
            let skullPath = UIBezierPath()
            skullPath.move(to: settings.batPoint(x: 56.71, y: 24))
            skullPath.addLine(to: settings.batPoint(x: 7.29, y: 24))
            skullPath.addCurve(to: settings.batPoint(x: 16.8, y: 11.44), controlPoint1: settings.batPoint(x: 9.53, y: 18.9), controlPoint2: settings.batPoint(x: 12.82, y: 14.58))
            skullPath.addCurve(to: settings.batPoint(x: 32, y: 6), controlPoint1: settings.batPoint(x: 21.17, y: 8), controlPoint2: settings.batPoint(x: 26.39, y: 6))
            skullPath.addCurve(to: settings.batPoint(x: 56.71, y: 24), controlPoint1: settings.batPoint(x: 42.7, y: 6), controlPoint2: settings.batPoint(x: 52, y: 13.29))
            skullPath.close()
            
            let rightEarNode = SKShapeNode(path:skullPath.cgPath)
            rightEarNode.fillColor =  skin
            rightEarNode.strokeColor = skullColor ?? .clear
            
            rightEarNode.name = "skull"
            
            headNode.addChild(rightEarNode)
            
        }
        
        for f in self.nodeMakers {
            let (name,fill,stroke,pathM) = f()
            let hairNode = SKShapeNode(path:pathM())
            hairNode.fillColor = fill
            hairNode.strokeColor = stroke ?? fill
            hairNode.name = name
            headNode.addChild(hairNode)
        }
        
        rootNode.name = "root"
        
    }
    
    
    func image()->UIImage{
        
        let ht:CGFloat = 200.0
        
        let render = UIGraphicsImageRenderer(size: CGSize(width: ht, height: ht))
        
        print("\n\nmaking image")
        return render.image{utc in
            /*
             let context = utc.cgContext
             let rotate = CGAffineTransform(rotationAngle: CGFloat.pi)
             let flipVertical:CGAffineTransform = CGAffineTransform(translationX: 0, y: -ht) //CGAffineTransformMake(1,0,0,-1,0,ht)
             context.concatenate(flipVertical)
             context.concatenate(rotate)
             */
            
            // UIColor.orange.setFill()
            
            
            // UIBezierPath(rect: CGRect(x: 0, y: 0, width: ht, height: ht)).fill()
            mask.setFill()
            
            
            
            
            UIBezierPath(cgPath: self.headMaker()).fill()
            
            if let f = self.faceMaker {
                skin.setFill()
                let p = f()
                
                UIBezierPath(cgPath:p).fill()
                
                lips.setFill()
                lips.setStroke()
                UIBezierPath(cgPath:settings.makeMouth(x: 18, y: 56)).fill()
                
            }
            
            let eyeHeight:CGFloat = 33
            
            eyes.setFill()
            
            UIColor.white.setFill()
            
            UIBezierPath(cgPath:settings.makeEye(x: 10, y: eyeHeight)).fill()
            UIBezierPath(cgPath:settings.makeEye(x: 41, y: eyeHeight)).fill()
            
            UIColor.black.setFill()
            UIColor.black.setStroke()
            UIBezierPath(cgPath:settings.makePupil(x: 15, y: eyeHeight)).fill()
            UIBezierPath(cgPath:settings.makePupil(x: 46, y: eyeHeight)).fill()
            
            
            
            if let _ = self.earMaker {
                /*
                 let (leftEarNode,rightEarNode) = e()
                 // let leftEarNode = SKShapeNode(path:makeEar(x:16,y:-0.5))
                 leftEarNode.fillColor = earColor ?? mask
                 leftEarNode.strokeColor = earColor ?? mask
                 leftEarNode.name = "leftEar"
                 rootNode.addChild(leftEarNode)
                 
                 //let rightEarNode = SKShapeNode(path:makeEar(x:47,y:-0.5))
                 rightEarNode.fillColor = earColor ?? mask
                 rightEarNode.name = "rightEar"
                 rightEarNode.strokeColor = earColor ?? mask
                 rootNode.addChild(rightEarNode)
                 */
            } else {
                
                let skullPath = UIBezierPath()
                skullPath.move(to: settings.batPoint(x: 56.71, y: 24))
                skullPath.addLine(to: settings.batPoint(x: 7.29, y: 24))
                skullPath.addCurve(to: settings.batPoint(x: 16.8, y: 11.44), controlPoint1: settings.batPoint(x: 9.53, y: 18.9), controlPoint2: settings.batPoint(x: 12.82, y: 14.58))
                skullPath.addCurve(to: settings.batPoint(x: 32, y: 6), controlPoint1: settings.batPoint(x: 21.17, y: 8), controlPoint2: settings.batPoint(x: 26.39, y: 6))
                skullPath.addCurve(to: settings.batPoint(x: 56.71, y: 24), controlPoint1: settings.batPoint(x: 42.7, y: 6), controlPoint2: settings.batPoint(x: 52, y: 13.29))
                skullPath.close()
                
                skin.setFill()
                let stro  = skullColor ?? .clear
                stro.setStroke()
                skullPath.fill()
                skullPath.stroke()
                
                
            }
            for f in self.nodeMakers {
                let (_,fill,stroke,pathM) = f()
                fill.setFill()
                let c = stroke ?? fill
                c.setStroke()
                
                let p =  UIBezierPath(cgPath:pathM())
                p.fill()
                p.stroke()
                
            }
        }
    }
}

func makeBatMan(_ rootNode:SKNode?, settings: DimensionSetting)->CharacterSpec{
    
    let mask = UIColor(red: 0.173, green: 0.106, blue: 0.401, alpha: 1.000)
    var batman = CharacterSpec(mask:mask, settings:settings)
    
    batman.earMaker = {
        return (SKShapeNode(path:settings.makeEar(x:16,y:-0.5)), SKShapeNode(path:settings.makeEar(x:47,y:-0.5)))
    }
    
    if let rootNode = rootNode {
        batman.node(rootNode: rootNode)
    }
    return batman
    
    
}

func makeBatGirl(_ rootNode:SKNode?, settings: DimensionSetting)->CharacterSpec{
    
    let mask = UIColor(red: 0.173, green: 0.106, blue: 0.401, alpha: 1.000)
    var batGirl = CharacterSpec(mask:mask, settings:settings)
    
    batGirl.earMaker = {
        return (SKShapeNode(path:settings.makeEar(x:16,y:-0.5)), SKShapeNode(path:settings.makeEar(x:47,y:-0.5)))
    }
    
    let hairN:NodeMaker = {
        return ("hair",UIColor(red: 0.756, green: 0.045, blue: 0.045, alpha: 1.000),nil, {
            let bezier7Path = UIBezierPath()
            
            bezier7Path.move(to: settings.batPoint(x: 59.28, y: 32.28))
            bezier7Path.addCurve(to: settings.batPoint(x: 70.82, y: 50.66), controlPoint1: settings.batPoint(x: 65.33, y: 35.06), controlPoint2: settings.batPoint(x: 69.87, y: 42.1))
            bezier7Path.addCurve(to: settings.batPoint(x: 76, y: 67), controlPoint1: settings.batPoint(x: 74.02, y: 54.83), controlPoint2: settings.batPoint(x: 76, y: 60.61))
            bezier7Path.addCurve(to: settings.batPoint(x: 65, y: 76), controlPoint1: settings.batPoint(x: 76, y: 79.7), controlPoint2: settings.batPoint(x: 74.66, y: 76))
            bezier7Path.addCurve(to: settings.batPoint(x: 41.42, y: 72.03), controlPoint1: settings.batPoint(x: 56.65, y: 76), controlPoint2: settings.batPoint(x: 43.16, y: 82.31))
            bezier7Path.addCurve(to: settings.batPoint(x: 60, y: 40), controlPoint1: settings.batPoint(x: 52.25, y: 67.33), controlPoint2: settings.batPoint(x: 60, y: 54.76))
            bezier7Path.addCurve(to: settings.batPoint(x: 59.28, y: 32.28), controlPoint1: settings.batPoint(x: 60, y: 37.35), controlPoint2: settings.batPoint(x: 59.75, y: 34.76))
            bezier7Path.close()
            bezier7Path.move(to: settings.batPoint(x: 4.72, y: 32.28))
            bezier7Path.addCurve(to: settings.batPoint(x: -6.82, y: 50.66), controlPoint1: settings.batPoint(x: -1.33, y: 35.06), controlPoint2: settings.batPoint(x: -5.87, y: 42.1))
            bezier7Path.addCurve(to: settings.batPoint(x: -12, y: 67), controlPoint1: settings.batPoint(x: -10.02, y: 54.83), controlPoint2: settings.batPoint(x: -12, y: 60.61))
            bezier7Path.addCurve(to: settings.batPoint(x: 4, y: 76), controlPoint1: settings.batPoint(x: -12, y: 79.7), controlPoint2: settings.batPoint(x: -5.66, y: 76))
            bezier7Path.addCurve(to: settings.batPoint(x: 22.58, y: 72.03), controlPoint1: settings.batPoint(x: 12.35, y: 76), controlPoint2: settings.batPoint(x: 20.84, y: 82.31))
            bezier7Path.addCurve(to: settings.batPoint(x: 4, y: 40), controlPoint1: settings.batPoint(x: 11.75, y: 67.33), controlPoint2: settings.batPoint(x: 4, y: 54.76))
            bezier7Path.addCurve(to: settings.batPoint(x: 4.72, y: 32.28), controlPoint1: settings.batPoint(x: 4, y: 37.35), controlPoint2: settings.batPoint(x: 4.25, y: 34.76))
            bezier7Path.close()
            return bezier7Path.cgPath
        })
    }
    
    batGirl.nodeMakers.append(hairN)
    
    if let rootNode = rootNode {
        batGirl.node(rootNode: rootNode)
    }
    return batGirl
}

func makeFlash(_ rootNode:SKNode?, settings: DimensionSetting)->CharacterSpec{
    
    var flash = CharacterSpec(mask:.red, settings:settings)
    flash.earMaker = {
        
        //// ear Drawing
        let earPath = UIBezierPath()
        earPath.move(to: settings.batPoint(x: 68, y: 3))
        earPath.addLine(to: settings.batPoint(x: 52, y: 10))
        earPath.addLine(to: settings.batPoint(x: 59, y: 19))
        earPath.fill()
        
        
        //// ear 2 Drawing
        let ear2Path = UIBezierPath()
        ear2Path.move(to: settings.batPoint(x: 0, y: 3))
        ear2Path.addLine(to: settings.batPoint(x: 16, y: 10))
        ear2Path.addLine(to: settings.batPoint(x: 9, y: 19))
        
        ear2Path.fill()
        
        return (SKShapeNode(path:earPath.cgPath), SKShapeNode(path:ear2Path.cgPath))
    }
    flash.earColor = UIColor(red: 1.000, green: 0.796, blue: 0.000, alpha: 1.000)
    if let rootNode = rootNode{
        flash.node(rootNode: rootNode)
    }
    return flash
    
}


func makeSuperman(_ rootNode:SKNode?, settings: DimensionSetting)->CharacterSpec{
    let maskColor = UIColor(red: 0.144, green: 0.170, blue: 0.450, alpha: 1.000)
    
    var superMan = CharacterSpec(mask:maskColor, settings:settings)//mask)
    
    let hairN:NodeMaker = {
        return ("hair",.black,nil, {
            
            let superhairPath = UIBezierPath()
            superhairPath.move(to: settings.batPoint(x: 51, y: 5))
            superhairPath.addCurve(to: settings.batPoint(x: 68, y: 33), controlPoint1: settings.batPoint(x: 53.7, y: 6.22), controlPoint2: settings.batPoint(x: 69, y: 23))
            superhairPath.addCurve(to: settings.batPoint(x: 65, y: 37), controlPoint1: settings.batPoint(x: 67.75, y: 35.5), controlPoint2: settings.batPoint(x: 67.07, y: 36.35))
            superhairPath.addCurve(to: settings.batPoint(x: 59, y: 37), controlPoint1: settings.batPoint(x: 63.51, y: 37.47), controlPoint2: settings.batPoint(x: 59.98, y: 36.52))
            superhairPath.addCurve(to: settings.batPoint(x: 27.06, y: 22.06), controlPoint1: settings.batPoint(x: 56.89, y: 23.21), controlPoint2: settings.batPoint(x: 44.38, y: 22.06))
            superhairPath.addCurve(to: settings.batPoint(x: 18.85, y: 22.89), controlPoint1: settings.batPoint(x: 24.23, y: 22.06), controlPoint2: settings.batPoint(x: 21.48, y: 22.35))
            superhairPath.addCurve(to: settings.batPoint(x: 10.06, y: 30.06), controlPoint1: settings.batPoint(x: 15.45, y: 24.35), controlPoint2: settings.batPoint(x: 12.39, y: 26.6))
            superhairPath.addCurve(to: settings.batPoint(x: 1.06, y: 37.06), controlPoint1: settings.batPoint(x: 8.94, y: 31.73), controlPoint2: settings.batPoint(x: 2.03, y: 34.83))
            superhairPath.addCurve(to: settings.batPoint(x: 1.06, y: 20.56), controlPoint1: settings.batPoint(x: -2.27, y: 34.28), controlPoint2: settings.batPoint(x: 1.06, y: 25.93))
            superhairPath.addCurve(to: settings.batPoint(x: 4.51, y: 8.39), controlPoint1: settings.batPoint(x: 1.06, y: 16.48), controlPoint2: settings.batPoint(x: 2.43, y: 11.15))
            superhairPath.addCurve(to: settings.batPoint(x: 13.56, y: 5.06), controlPoint1: settings.batPoint(x: 6.79, y: 5.35), controlPoint2: settings.batPoint(x: 9.95, y: 5.06))
            superhairPath.addCurve(to: settings.batPoint(x: 15.31, y: 5.21), controlPoint1: settings.batPoint(x: 14.16, y: 5.06), controlPoint2: settings.batPoint(x: 14.74, y: 5.11))
            superhairPath.addCurve(to: settings.batPoint(x: 15.69, y: 4.65), controlPoint1: settings.batPoint(x: 15.43, y: 5.02), controlPoint2: settings.batPoint(x: 15.56, y: 4.84))
            superhairPath.addCurve(to: settings.batPoint(x: 19.04, y: 1.79), controlPoint1: settings.batPoint(x: 16.56, y: 3.47), controlPoint2: settings.batPoint(x: 17.69, y: 2.52))
            superhairPath.addCurve(to: settings.batPoint(x: 51, y: 5), controlPoint1: settings.batPoint(x: 26.59, y: -2.29), controlPoint2: settings.batPoint(x: 40.79, y: 0.4))
            superhairPath.close()
            return superhairPath.cgPath
        } )
    }
    
    superMan.nodeMakers.append(hairN)
    
    let sheildN:NodeMaker = {
        return ("shield", UIColor(red: 1.000, green: 0.796, blue: 0.000, alpha: 1.000), nil, {
            let trianglePath = UIBezierPath()
            trianglePath.move(to: settings.batPoint(x: 32.19, y: 40.3))
            trianglePath.addLine(to: settings.batPoint(x: 39.82, y: 25.19))
            trianglePath.addLine(to: settings.batPoint(x: 24.56, y: 25.19))
            trianglePath.close()
            return trianglePath.cgPath
        })
    }
    
    superMan.nodeMakers.append(sheildN)
    
    let SN:NodeMaker = {
        return ("s",.red,nil, settings.makeS)
    }
    
    superMan.nodeMakers.append(SN)
    
    if let rootNode = rootNode{
        superMan.node(rootNode: rootNode)
    }
    
    return superMan
    
}



func makeWonderWoman(_ rootNode:SKNode?, settings: DimensionSetting) ->CharacterSpec{
    
    var wonderWoman = CharacterSpec(mask:UIColor(red: 0.998, green: 0.895, blue: 0.855, alpha: 1.000), settings:settings)
    
    let hairN:NodeMaker = {
        return ("hair", UIColor(red: 0.165, green: 0.092, blue: 0.048, alpha: 1.000),nil, {
            
            let wonderPath = UIBezierPath()
            wonderPath.move(to: settings.batPoint(x: 65, y: 15))
            wonderPath.addCurve(to: settings.batPoint(x: 74, y: 32), controlPoint1: settings.batPoint(x: 66.88, y: 17.58), controlPoint2: settings.batPoint(x: 72.78, y: 29.3))
            wonderPath.addCurve(to: settings.batPoint(x: 75.41, y: 56.37), controlPoint1: settings.batPoint(x: 79.42, y: 44.03), controlPoint2: settings.batPoint(x: 83.26, y: 50.67))
            wonderPath.addCurve(to: settings.batPoint(x: 74.85, y: 56.76), controlPoint1: settings.batPoint(x: 75.23, y: 56.5), controlPoint2: settings.batPoint(x: 75.04, y: 56.63))
            wonderPath.addCurve(to: settings.batPoint(x: 75, y: 58.5), controlPoint1: settings.batPoint(x: 74.95, y: 57.33), controlPoint2: settings.batPoint(x: 75, y: 57.91))
            wonderPath.addCurve(to: settings.batPoint(x: 71.68, y: 67.55), controlPoint1: settings.batPoint(x: 75, y: 62.11), controlPoint2: settings.batPoint(x: 74.72, y: 65.27))
            wonderPath.addCurve(to: settings.batPoint(x: 59.5, y: 71), controlPoint1: settings.batPoint(x: 68.91, y: 69.63), controlPoint2: settings.batPoint(x: 63.58, y: 71))
            wonderPath.addCurve(to: settings.batPoint(x: 43, y: 71), controlPoint1: settings.batPoint(x: 54.14, y: 71), controlPoint2: settings.batPoint(x: 45.78, y: 74.34))
            wonderPath.addCurve(to: settings.batPoint(x: 50, y: 62), controlPoint1: settings.batPoint(x: 45.23, y: 70.04), controlPoint2: settings.batPoint(x: 48.33, y: 63.12))
            wonderPath.addCurve(to: settings.batPoint(x: 57.18, y: 53.21), controlPoint1: settings.batPoint(x: 53.46, y: 59.67), controlPoint2: settings.batPoint(x: 55.72, y: 56.62))
            wonderPath.addCurve(to: settings.batPoint(x: 58, y: 45), controlPoint1: settings.batPoint(x: 57.72, y: 50.58), controlPoint2: settings.batPoint(x: 58, y: 47.83))
            wonderPath.addCurve(to: settings.batPoint(x: 32, y: 11.65), controlPoint1: settings.batPoint(x: 58, y: 28.93), controlPoint2: settings.batPoint(x: 44.91, y: 15.23))
            wonderPath.addCurve(to: settings.batPoint(x: 6, y: 45), controlPoint1: settings.batPoint(x: 19.09, y: 15.23), controlPoint2: settings.batPoint(x: 6, y: 28.93))
            wonderPath.addCurve(to: settings.batPoint(x: 6.82, y: 53.21), controlPoint1: settings.batPoint(x: 6, y: 47.83), controlPoint2: settings.batPoint(x: 6.28, y: 50.58))
            wonderPath.addCurve(to: settings.batPoint(x: 14, y: 62), controlPoint1: settings.batPoint(x: 8.28, y: 56.62), controlPoint2: settings.batPoint(x: 10.54, y: 59.67))
            wonderPath.addCurve(to: settings.batPoint(x: 21, y: 71), controlPoint1: settings.batPoint(x: 15.67, y: 63.12), controlPoint2: settings.batPoint(x: 18.77, y: 70.04))
            wonderPath.addCurve(to: settings.batPoint(x: 4.5, y: 71), controlPoint1: settings.batPoint(x: 18.22, y: 74.34), controlPoint2: settings.batPoint(x: 9.86, y: 71))
            wonderPath.addCurve(to: settings.batPoint(x: -7.68, y: 67.55), controlPoint1: settings.batPoint(x: 0.42, y: 71), controlPoint2: settings.batPoint(x: -4.91, y: 69.63))
            wonderPath.addCurve(to: settings.batPoint(x: -11, y: 58.5), controlPoint1: settings.batPoint(x: -10.72, y: 65.27), controlPoint2: settings.batPoint(x: -11, y: 62.11))
            wonderPath.addCurve(to: settings.batPoint(x: -10.85, y: 56.76), controlPoint1: settings.batPoint(x: -11, y: 57.91), controlPoint2: settings.batPoint(x: -10.95, y: 57.33))
            wonderPath.addCurve(to: settings.batPoint(x: -11.41, y: 56.37), controlPoint1: settings.batPoint(x: -11.04, y: 56.63), controlPoint2: settings.batPoint(x: -11.23, y: 56.5))
            wonderPath.addCurve(to: settings.batPoint(x: -10, y: 32), controlPoint1: settings.batPoint(x: -19.26, y: 50.67), controlPoint2: settings.batPoint(x: -15.42, y: 44.03))
            wonderPath.addCurve(to: settings.batPoint(x: -1, y: 15), controlPoint1: settings.batPoint(x: -8.78, y: 29.3), controlPoint2: settings.batPoint(x: -2.88, y: 17.58))
            wonderPath.addCurve(to: settings.batPoint(x: 31, y: 2), controlPoint1: settings.batPoint(x: 9.22, y: 0.92), controlPoint2: settings.batPoint(x: 21.39, y: -4.98))
            wonderPath.addCurve(to: settings.batPoint(x: 32, y: 3.11), controlPoint1: settings.batPoint(x: 31.37, y: 2.27), controlPoint2: settings.batPoint(x: 31.7, y: 2.65))
            wonderPath.addCurve(to: settings.batPoint(x: 33, y: 2), controlPoint1: settings.batPoint(x: 32.3, y: 2.65), controlPoint2: settings.batPoint(x: 32.63, y: 2.27))
            wonderPath.addCurve(to: settings.batPoint(x: 65, y: 15), controlPoint1: settings.batPoint(x: 42.61, y: -4.98), controlPoint2: settings.batPoint(x: 54.78, y: 0.92))
            wonderPath.close()
            return wonderPath.cgPath
        })
        
    }
    
    wonderWoman.nodeMakers.append(hairN)
    
    let crownN:NodeMaker = {
        return ("crown",UIColor(red: 1.000, green: 0.796, blue: 0.000, alpha: 1.000),.black,{
            let crownPath = UIBezierPath()
            crownPath.move(to: settings.batPoint(x: 32, y: 7.5))
            crownPath.addCurve(to: settings.batPoint(x: 50.07, y: 14.06), controlPoint1: settings.batPoint(x: 32, y: 7.5), controlPoint2: settings.batPoint(x: 50.07, y: 14.06))
            crownPath.addCurve(to: settings.batPoint(x: 48.16, y: 17), controlPoint1: settings.batPoint(x: 50.07, y: 14.06), controlPoint2: settings.batPoint(x: 49.24, y: 15.34))
            crownPath.addLine(to: settings.batPoint(x: 53, y: 17))
            crownPath.addLine(to: settings.batPoint(x: 53, y: 28))
            crownPath.addLine(to: settings.batPoint(x: 11, y: 28))
            crownPath.addLine(to: settings.batPoint(x: 11, y: 17))
            crownPath.addLine(to: settings.batPoint(x: 15.84, y: 17))
            crownPath.addCurve(to: settings.batPoint(x: 13.93, y: 14.06), controlPoint1: settings.batPoint(x: 14.76, y: 15.34), controlPoint2: settings.batPoint(x: 13.93, y: 14.06))
            crownPath.addCurve(to: settings.batPoint(x: 20.45, y: 11.7), controlPoint1: settings.batPoint(x: 13.93, y: 14.06), controlPoint2: settings.batPoint(x: 16.91, y: 12.98))
            crownPath.addCurve(to: settings.batPoint(x: 32, y: 7.5), controlPoint1: settings.batPoint(x: 25.63, y: 9.81), controlPoint2: settings.batPoint(x: 32, y: 7.5))
            crownPath.addLine(to: settings.batPoint(x: 32, y: 7.5))
            crownPath.close()
            return crownPath.cgPath
        })
    }
    
    wonderWoman.nodeMakers.append(crownN)
    
    let startN:NodeMaker = {
        return ("star",.red,.black, {
            let starPath = UIBezierPath()
            starPath.move(to: settings.batPoint(x: 32, y: 13))
            starPath.addLine(to: settings.batPoint(x: 34.47, y: 16.34))
            starPath.addLine(to: settings.batPoint(x: 38.66, y: 17.49))
            starPath.addLine(to: settings.batPoint(x: 35.99, y: 20.71))
            starPath.addLine(to: settings.batPoint(x: 36.11, y: 24.76))
            starPath.addLine(to: settings.batPoint(x: 32, y: 23.4))
            starPath.addLine(to: settings.batPoint(x: 27.89, y: 24.76))
            starPath.addLine(to: settings.batPoint(x: 28.01, y: 20.71))
            starPath.addLine(to: settings.batPoint(x: 25.34, y: 17.49))
            starPath.addLine(to: settings.batPoint(x: 29.53, y: 16.34))
            starPath.close()
            return starPath.cgPath
        })
    }
    
    wonderWoman.nodeMakers.append(startN)
    
    if let rootNode = rootNode {
        wonderWoman.node(rootNode: (rootNode))
    }
    
    return wonderWoman
    
}



func makeSuperGirl(_ rootNode:SKNode?, settings: DimensionSetting)->CharacterSpec{
    
    var superGirl = CharacterSpec(mask: UIColor(red: 0.144, green: 0.170, blue: 0.450, alpha: 1.000), settings:settings)
    
    let hairN:NodeMaker = {
        return ("hair", UIColor(red: 1.000, green: 0.932, blue: 0.634, alpha: 1.000),.black, {
            
            let wonderPath = UIBezierPath()
            wonderPath.move(to: settings.batPoint(x: 65, y: 15))
            wonderPath.addCurve(to: settings.batPoint(x: 74, y: 32), controlPoint1: settings.batPoint(x: 66.88, y: 17.58), controlPoint2: settings.batPoint(x: 72.78, y: 29.3))
            wonderPath.addCurve(to: settings.batPoint(x: 75.41, y: 56.37), controlPoint1: settings.batPoint(x: 79.42, y: 44.03), controlPoint2: settings.batPoint(x: 83.26, y: 50.67))
            wonderPath.addCurve(to: settings.batPoint(x: 74.85, y: 56.76), controlPoint1: settings.batPoint(x: 75.23, y: 56.5), controlPoint2: settings.batPoint(x: 75.04, y: 56.63))
            wonderPath.addCurve(to: settings.batPoint(x: 75, y: 58.5), controlPoint1: settings.batPoint(x: 74.95, y: 57.33), controlPoint2: settings.batPoint(x: 75, y: 57.91))
            wonderPath.addCurve(to: settings.batPoint(x: 71.68, y: 67.55), controlPoint1: settings.batPoint(x: 75, y: 62.11), controlPoint2: settings.batPoint(x: 74.72, y: 65.27))
            wonderPath.addCurve(to: settings.batPoint(x: 59.5, y: 71), controlPoint1: settings.batPoint(x: 68.91, y: 69.63), controlPoint2: settings.batPoint(x: 63.58, y: 71))
            wonderPath.addCurve(to: settings.batPoint(x: 43, y: 71), controlPoint1: settings.batPoint(x: 54.14, y: 71), controlPoint2: settings.batPoint(x: 45.78, y: 74.34))
            wonderPath.addCurve(to: settings.batPoint(x: 50, y: 62), controlPoint1: settings.batPoint(x: 45.23, y: 70.04), controlPoint2: settings.batPoint(x: 48.33, y: 63.12))
            wonderPath.addCurve(to: settings.batPoint(x: 57.18, y: 53.21), controlPoint1: settings.batPoint(x: 53.46, y: 59.67), controlPoint2: settings.batPoint(x: 55.72, y: 56.62))
            wonderPath.addCurve(to: settings.batPoint(x: 58, y: 45), controlPoint1: settings.batPoint(x: 57.72, y: 50.58), controlPoint2: settings.batPoint(x: 58, y: 47.83))
            wonderPath.addCurve(to: settings.batPoint(x: 32, y: 11.65), controlPoint1: settings.batPoint(x: 58, y: 28.93), controlPoint2: settings.batPoint(x: 44.91, y: 15.23))
            wonderPath.addCurve(to: settings.batPoint(x: 6, y: 45), controlPoint1: settings.batPoint(x: 19.09, y: 15.23), controlPoint2: settings.batPoint(x: 6, y: 28.93))
            wonderPath.addCurve(to: settings.batPoint(x: 6.82, y: 53.21), controlPoint1: settings.batPoint(x: 6, y: 47.83), controlPoint2: settings.batPoint(x: 6.28, y: 50.58))
            wonderPath.addCurve(to: settings.batPoint(x: 14, y: 62), controlPoint1: settings.batPoint(x: 8.28, y: 56.62), controlPoint2: settings.batPoint(x: 10.54, y: 59.67))
            wonderPath.addCurve(to: settings.batPoint(x: 21, y: 71), controlPoint1: settings.batPoint(x: 15.67, y: 63.12), controlPoint2: settings.batPoint(x: 18.77, y: 70.04))
            wonderPath.addCurve(to: settings.batPoint(x: 4.5, y: 71), controlPoint1: settings.batPoint(x: 18.22, y: 74.34), controlPoint2: settings.batPoint(x: 9.86, y: 71))
            wonderPath.addCurve(to: settings.batPoint(x: -7.68, y: 67.55), controlPoint1: settings.batPoint(x: 0.42, y: 71), controlPoint2: settings.batPoint(x: -4.91, y: 69.63))
            wonderPath.addCurve(to: settings.batPoint(x: -11, y: 58.5), controlPoint1: settings.batPoint(x: -10.72, y: 65.27), controlPoint2: settings.batPoint(x: -11, y: 62.11))
            wonderPath.addCurve(to: settings.batPoint(x: -10.85, y: 56.76), controlPoint1: settings.batPoint(x: -11, y: 57.91), controlPoint2: settings.batPoint(x: -10.95, y: 57.33))
            wonderPath.addCurve(to: settings.batPoint(x: -11.41, y: 56.37), controlPoint1: settings.batPoint(x: -11.04, y: 56.63), controlPoint2: settings.batPoint(x: -11.23, y: 56.5))
            wonderPath.addCurve(to: settings.batPoint(x: -10, y: 32), controlPoint1: settings.batPoint(x: -19.26, y: 50.67), controlPoint2: settings.batPoint(x: -15.42, y: 44.03))
            wonderPath.addCurve(to: settings.batPoint(x: -1, y: 15), controlPoint1: settings.batPoint(x: -8.78, y: 29.3), controlPoint2: settings.batPoint(x: -2.88, y: 17.58))
            wonderPath.addCurve(to: settings.batPoint(x: 31, y: 2), controlPoint1: settings.batPoint(x: 9.22, y: 0.92), controlPoint2: settings.batPoint(x: 21.39, y: -4.98))
            wonderPath.addCurve(to: settings.batPoint(x: 32, y: 3.11), controlPoint1: settings.batPoint(x: 31.37, y: 2.27), controlPoint2: settings.batPoint(x: 31.7, y: 2.65))
            wonderPath.addCurve(to: settings.batPoint(x: 33, y: 2), controlPoint1: settings.batPoint(x: 32.3, y: 2.65), controlPoint2: settings.batPoint(x: 32.63, y: 2.27))
            wonderPath.addCurve(to: settings.batPoint(x: 65, y: 15), controlPoint1: settings.batPoint(x: 42.61, y: -4.98), controlPoint2: settings.batPoint(x: 54.78, y: 0.92))
            wonderPath.close()
            return wonderPath.cgPath
        })
    }
    superGirl.nodeMakers.append(hairN)
    
    
    let shieldN:NodeMaker = {
        return ("sheild",UIColor(red: 1.000, green: 0.796, blue: 0.000, alpha: 1.000),nil , {
            
            let trianglePath = UIBezierPath()
            trianglePath.move(to: settings.batPoint(x: 32.19, y: 40.3))
            trianglePath.addLine(to: settings.batPoint(x: 39.82, y: 25.19))
            trianglePath.addLine(to: settings.batPoint(x: 24.56, y: 25.19))
            trianglePath.close()
            return trianglePath.cgPath
        })
    }
    
    superGirl.nodeMakers.append(shieldN)
    
    let SN:NodeMaker = {
        return ("s",.red,nil, settings.makeS)
    }
    
    superGirl.nodeMakers.append(SN)
    
    if let rootNode = rootNode{
        superGirl.node(rootNode: rootNode)
    }
    
    return superGirl
    
    
    
    
}

func makeHulk(_ rootNode:SKNode?, settings: DimensionSetting)->CharacterSpec{
    
    let mask = UIColor(red: 0.144, green: 0.428, blue: 0.170, alpha: 1.000)
    var hulk = CharacterSpec(mask:mask, settings:settings)
    hulk.skin = mask
    
    // robin.faceMaker = nil
    hulk.headMaker = {
        let hulkheadPath = UIBezierPath()
        hulkheadPath.move(to: settings.batPoint(x: 53, y: 12))
        hulkheadPath.addCurve(to: settings.batPoint(x: 60, y: 25), controlPoint1: settings.batPoint(x: 53, y: 12), controlPoint2: settings.batPoint(x: 60, y: 17.42))
        hulkheadPath.addCurve(to: settings.batPoint(x: 60, y: 45.5), controlPoint1: settings.batPoint(x: 60, y: 31.09), controlPoint2: settings.batPoint(x: 60, y: 38.62))
        hulkheadPath.addCurve(to: settings.batPoint(x: 60, y: 60.28), controlPoint1: settings.batPoint(x: 60, y: 57.07), controlPoint2: settings.batPoint(x: 60, y: 60.28))
        hulkheadPath.addLine(to: settings.batPoint(x: 53.35, y: 67.18))
        hulkheadPath.addCurve(to: settings.batPoint(x: 32, y: 79), controlPoint1: settings.batPoint(x: 48.21, y: 74.41), controlPoint2: settings.batPoint(x: 40.55, y: 79))
        hulkheadPath.addCurve(to: settings.batPoint(x: 10.65, y: 67.18), controlPoint1: settings.batPoint(x: 23.45, y: 79), controlPoint2: settings.batPoint(x: 15.79, y: 74.41))
        hulkheadPath.addLine(to: settings.batPoint(x: 4, y: 60.28))
        hulkheadPath.addLine(to: settings.batPoint(x: 4, y: 25))
        hulkheadPath.addLine(to: settings.batPoint(x: 11, y: 12))
        hulkheadPath.addLine(to: settings.batPoint(x: 60, y: 12))
        hulkheadPath.addLine(to: settings.batPoint(x: 53, y: 12))
        return hulkheadPath.cgPath
    }
    
    let hairN:NodeMaker = {
        return ("hair", .black,nil, {
            
            let superhairPath = UIBezierPath()
            superhairPath.move(to: settings.batPoint(x: 15.79, y: 5.03))
            superhairPath.addCurve(to: settings.batPoint(x: 0.04, y: 32.01), controlPoint1: settings.batPoint(x: 13.29, y: 6.2), controlPoint2: settings.batPoint(x: -0.88, y: 22.38))
            superhairPath.addCurve(to: settings.batPoint(x: 2.82, y: 35.87), controlPoint1: settings.batPoint(x: 0.28, y: 34.42), controlPoint2: settings.batPoint(x: 0.91, y: 35.24))
            superhairPath.addCurve(to: settings.batPoint(x: 9, y: 32), controlPoint1: settings.batPoint(x: 4.2, y: 36.32), controlPoint2: settings.batPoint(x: 8.09, y: 31.54))
            superhairPath.addCurve(to: settings.batPoint(x: 29, y: 15), controlPoint1: settings.batPoint(x: 10.96, y: 18.71), controlPoint2: settings.batPoint(x: 12.96, y: 15))
            superhairPath.addCurve(to: settings.batPoint(x: 45, y: 20), controlPoint1: settings.batPoint(x: 31.62, y: 15), controlPoint2: settings.batPoint(x: 42.56, y: 19.48))
            superhairPath.addCurve(to: settings.batPoint(x: 53.71, y: 29.18), controlPoint1: settings.batPoint(x: 48.16, y: 21.41), controlPoint2: settings.batPoint(x: 51.55, y: 25.85))
            superhairPath.addCurve(to: settings.batPoint(x: 62.05, y: 35.93), controlPoint1: settings.batPoint(x: 54.75, y: 30.79), controlPoint2: settings.batPoint(x: 61.15, y: 33.78))
            superhairPath.addCurve(to: settings.batPoint(x: 62.05, y: 20.03), controlPoint1: settings.batPoint(x: 65.14, y: 33.25), controlPoint2: settings.batPoint(x: 62.05, y: 25.2))
            superhairPath.addCurve(to: settings.batPoint(x: 58.85, y: 8.29), controlPoint1: settings.batPoint(x: 62.05, y: 16.1), controlPoint2: settings.batPoint(x: 60.78, y: 10.96))
            superhairPath.addCurve(to: settings.batPoint(x: 50.47, y: 5.09), controlPoint1: settings.batPoint(x: 56.74, y: 5.36), controlPoint2: settings.batPoint(x: 53.81, y: 5.09))
            superhairPath.addCurve(to: settings.batPoint(x: 48.85, y: 5.23), controlPoint1: settings.batPoint(x: 49.92, y: 5.09), controlPoint2: settings.batPoint(x: 49.38, y: 5.14))
            superhairPath.addCurve(to: settings.batPoint(x: 48.49, y: 4.69), controlPoint1: settings.batPoint(x: 48.74, y: 5.05), controlPoint2: settings.batPoint(x: 48.62, y: 4.87))
            superhairPath.addCurve(to: settings.batPoint(x: 45.39, y: 1.93), controlPoint1: settings.batPoint(x: 47.69, y: 3.55), controlPoint2: settings.batPoint(x: 46.64, y: 2.64))
            superhairPath.addCurve(to: settings.batPoint(x: 15.79, y: 5.03), controlPoint1: settings.batPoint(x: 38.4, y: -2), controlPoint2: settings.batPoint(x: 25.25, y: 0.59))
            superhairPath.close()
            return superhairPath.cgPath
            
        })
    }
    
    hulk.nodeMakers.append( hairN)
    
    if let rootNode = rootNode {
        hulk.node(rootNode: (rootNode))
    }
    
    return hulk
    
}

func makeRobin(_ rootNode:SKNode?, settings: DimensionSetting)->CharacterSpec{
    
    let mask = UIColor(red: 0.144, green: 0.428, blue: 0.170, alpha: 1.000)
    var robin = CharacterSpec(mask:mask, settings:settings)
    
    let hairN:NodeMaker = {
        return ("hair", UIColor(red: 0.326, green: 0.117, blue: 0.059, alpha: 1.000),nil, {
            
            let superhairPath = UIBezierPath()
            superhairPath.move(to: settings.batPoint(x: 15.79, y: 5.03))
            superhairPath.addCurve(to: settings.batPoint(x: 0.04, y: 32.01), controlPoint1: settings.batPoint(x: 13.29, y: 6.2), controlPoint2: settings.batPoint(x: -0.88, y: 22.38))
            superhairPath.addCurve(to: settings.batPoint(x: 2.82, y: 35.87), controlPoint1: settings.batPoint(x: 0.28, y: 34.42), controlPoint2: settings.batPoint(x: 0.91, y: 35.24))
            superhairPath.addCurve(to: settings.batPoint(x: 9, y: 32), controlPoint1: settings.batPoint(x: 4.2, y: 36.32), controlPoint2: settings.batPoint(x: 8.09, y: 31.54))
            superhairPath.addCurve(to: settings.batPoint(x: 29, y: 15), controlPoint1: settings.batPoint(x: 10.96, y: 18.71), controlPoint2: settings.batPoint(x: 12.96, y: 15))
            superhairPath.addCurve(to: settings.batPoint(x: 45, y: 20), controlPoint1: settings.batPoint(x: 31.62, y: 15), controlPoint2: settings.batPoint(x: 42.56, y: 19.48))
            superhairPath.addCurve(to: settings.batPoint(x: 53.71, y: 29.18), controlPoint1: settings.batPoint(x: 48.16, y: 21.41), controlPoint2: settings.batPoint(x: 51.55, y: 25.85))
            superhairPath.addCurve(to: settings.batPoint(x: 62.05, y: 35.93), controlPoint1: settings.batPoint(x: 54.75, y: 30.79), controlPoint2: settings.batPoint(x: 61.15, y: 33.78))
            superhairPath.addCurve(to: settings.batPoint(x: 62.05, y: 20.03), controlPoint1: settings.batPoint(x: 65.14, y: 33.25), controlPoint2: settings.batPoint(x: 62.05, y: 25.2))
            superhairPath.addCurve(to: settings.batPoint(x: 58.85, y: 8.29), controlPoint1: settings.batPoint(x: 62.05, y: 16.1), controlPoint2: settings.batPoint(x: 60.78, y: 10.96))
            superhairPath.addCurve(to: settings.batPoint(x: 50.47, y: 5.09), controlPoint1: settings.batPoint(x: 56.74, y: 5.36), controlPoint2: settings.batPoint(x: 53.81, y: 5.09))
            superhairPath.addCurve(to: settings.batPoint(x: 48.85, y: 5.23), controlPoint1: settings.batPoint(x: 49.92, y: 5.09), controlPoint2: settings.batPoint(x: 49.38, y: 5.14))
            superhairPath.addCurve(to: settings.batPoint(x: 48.49, y: 4.69), controlPoint1: settings.batPoint(x: 48.74, y: 5.05), controlPoint2: settings.batPoint(x: 48.62, y: 4.87))
            superhairPath.addCurve(to: settings.batPoint(x: 45.39, y: 1.93), controlPoint1: settings.batPoint(x: 47.69, y: 3.55), controlPoint2: settings.batPoint(x: 46.64, y: 2.64))
            superhairPath.addCurve(to: settings.batPoint(x: 15.79, y: 5.03), controlPoint1: settings.batPoint(x: 38.4, y: -2), controlPoint2: settings.batPoint(x: 25.25, y: 0.59))
            superhairPath.close()
            return superhairPath.cgPath
            
        })
    }
    
    robin.nodeMakers.append( hairN)
    
    if let rootNode = rootNode {
        robin.node(rootNode: (rootNode))
    }
    
    return robin
    
}


extension CharacterSpec {
    
    
    static func makeCast()->[(String,CharacterBuilder)]{
        var ret:[(String,CharacterBuilder)] = []
        ret.append(("Superman", makeSuperman))
        ret.append(("Supergirl", makeSuperGirl))
        ret.append(("Hulk", makeHulk))
        ret.append(("Robin", makeRobin))
        ret.append(("Wonderwoman", makeWonderWoman))
        ret.append(("Flash", makeFlash))
        ret.append(("Batman", makeBatMan))
        ret.append(("Batgirl", makeBatGirl))

        return ret
        
    }
    
}

