//
//  DimensionSetting.swift
//  SuperDetector
//
//  Created by Arthur  on 8/4/17.
//  Copyright © 2017 Arthur . All rights reserved.
//

import Foundation
import SpriteKit

struct DimensionSetting {
    
    var scaleX:CGFloat = 1
    var scaleY:CGFloat = 1
    var xOff:CGFloat = 50.0
    var yOff:CGFloat = 50.0
    

    mutating func normalize(){
        xOff = 0
        yOff = 0
        scaleX = 0.5
        scaleY = -0.5
        
    }
    func batPoint(x:CGFloat,y:CGFloat)->CGPoint{
        let newx = scaleX * (x * 2 - xOff)
        let newy = scaleY * ((2*yOff) - (2 * y))
        let p =  CGPoint(x: newx, y: newy)
       // print("\(p)")
        return p
    }
    
    
    func convertRect(_ label:String, x:CGFloat,y:CGFloat,width:CGFloat,height:CGFloat)->CGRect{
        
       
        return batRect(x:x,y:y,width:width,height:height) /*
        let newx = scaleX * (x * 2 - xOff)
        let newy = scaleY * (y  - yOff )// 100 - (2 * y))
        let origin = CGPoint(x:newx,y:newy)
        
        let size = CGSize(width: abs(width *  scaleX), height: abs( height * scaleY))
        return CGRect(origin: origin, size: size)
 */
        
    }
    
    func batRect(x:CGFloat,y:CGFloat,width:CGFloat,height:CGFloat)->CGRect{
        /*
        let newx = scaleX * (x * 2 - xOff)
        let newy = scaleY * (y  - yOff )// 100 - (2 * y))
        let origin = CGPoint(x:newx,y:newy)
        */
        
        let size = CGSize(width: abs(width * 2 * scaleX), height: abs(height * 2*scaleY))
        
        let origin:CGPoint
            
        if scaleY < 0 {
           origin = batPoint(x: x, y: y)
        } else {
            origin = batPoint(x: x, y: y + size.height)
        }
        let r = CGRect(origin: origin, size: size)
        print("\(r)")
        return r
    }
    
    func faceRect  (x:CGFloat,y:CGFloat,width:CGFloat,height:CGFloat)->CGRect{
        let newx = scaleX * (x * 2 - xOff)
        let newy = scaleY * ( y  - ( 2 * yOff) ) // 100 - (2 * y)
        let origin = CGPoint(x:newx,y:newy)
        let size = CGSize(width: abs(width * 4 * scaleX), height: abs(height * 4 * scaleY))
        return CGRect(origin: origin, size: size)
    }
    
    func makeEar(x:CGFloat,y:CGFloat) ->CGPath{
        let rightEarPath = UIBezierPath()
        rightEarPath.move(to: batPoint(x: x, y: y))
        rightEarPath.addLine(to: batPoint(x: x + 5.72, y: 12.95 + y))
        rightEarPath.addLine(to: batPoint(x: x + 9.53, y: 27.75 + y))
        rightEarPath.addLine(to: batPoint(x: x, y: 29.6 + y))
        rightEarPath.addLine(to: batPoint(x: x-9.53, y: 27.75 + y))
        rightEarPath.addLine(to: batPoint(x: x-5.72, y: 12.95 + y))
        rightEarPath.close()
        return rightEarPath.cgPath
    }
    
    func makeEye(x:CGFloat,y:CGFloat) ->CGPath{
        //  let base = batPoint(x: x, y: y)
        let path = UIBezierPath( ovalIn: convertRect("eye",x:x, y: y, width: 12, height: 6))
        return path.cgPath
    }
    
    func makePupil(x:CGFloat,y:CGFloat) ->CGPath{
        // let base = batPoint(x: x, y: y)
        let path = UIBezierPath( ovalIn: convertRect("pupil",x: x, y:y, width: 4, height: 4))
        return path.cgPath
    }
    
    func makeMouth(x:CGFloat,y:CGFloat) ->CGPath{
        //let base = batPoint(x: x, y: y)
        let path = UIBezierPath( ovalIn: convertRect("mouth",x: x, y: y, width: 28, height: 1))
        return path.cgPath
    }
    
    
    func makeHead()->CGPath{
        //let base = batPoint(x: x, y: y)
        /*
        let headPath = UIBezierPath(ovalIn: convertRect(x: x, y: y, width: 56, height: 68))
        return headPath.cgPath
 */
        
        //x:4,y:6
        /*
        let x:CGFloat = 4.0
        let y:CGFloat = 6.0
        let width:CGFloat = 56.0
        let height:CGFloat = 68.0
        
        let size = CGSize(width: abs(width * 2 * scaleX), height: abs(height * 2*scaleY))
        let origin:CGPoint
        
        if scaleY < 0 {
            origin = batPoint(x: x, y: y)
        } else {
            origin = batPoint(x: x, y: y + size.height + yOff)
        }
        
        let r = CGRect(origin: origin, size: size)
        
        
         print("making head with \(xOff) \(yOff) \(scaleX) \(scaleY) is \(r)")
       let headPath = UIBezierPath(ovalIn: r)
        return headPath.cgPath
 */
        let head2Path = UIBezierPath()
        head2Path.move(to: batPoint(x: 60, y: 40))
        head2Path.addCurve(to: batPoint(x: 32, y: 74), controlPoint1: batPoint(x: 60, y: 58.78), controlPoint2: batPoint(x: 47.46, y: 74))
        head2Path.addCurve(to: batPoint(x: 4, y: 40), controlPoint1: batPoint(x: 16.54, y: 74), controlPoint2: batPoint(x: 4, y: 58.78))
        head2Path.addCurve(to: batPoint(x: 32, y: 6), controlPoint1: batPoint(x: 4, y: 21.22), controlPoint2: batPoint(x: 16.54, y: 6))
        head2Path.addCurve(to: batPoint(x: 60, y: 40), controlPoint1: batPoint(x: 47.46, y: 6), controlPoint2: batPoint(x: 60, y: 21.22))
        return head2Path.cgPath
        
    }
    
    func makeFace() ->CGPath{
        let facePath = UIBezierPath()
        facePath.move(to: batPoint(x: 59.81, y: 44))
        facePath.addCurve(to: batPoint(x: 32, y: 74), controlPoint1: batPoint(x: 58.18, y: 60.89), controlPoint2: batPoint(x: 46.35, y: 74))
        facePath.addCurve(to: batPoint(x: 4.19, y: 44), controlPoint1: batPoint(x: 17.65, y: 74), controlPoint2: batPoint(x: 5.82, y: 60.89))
        facePath.addLine(to: batPoint(x: 59.81, y: 44))
        facePath.close()
        return facePath.cgPath
    }
    
    
    func makeS() -> CGPath {
        let superletterPath = UIBezierPath()
        superletterPath.move(to: batPoint(x: 34.46, y: 28.43))
        superletterPath.addLine(to: batPoint(x: 35.61, y: 28.43))
        superletterPath.addCurve(to: batPoint(x: 35.33, y: 27.14), controlPoint1: batPoint(x: 35.6, y: 27.93), controlPoint2: batPoint(x: 35.5, y: 27.5))
        superletterPath.addCurve(to: batPoint(x: 34.61, y: 26.25), controlPoint1: batPoint(x: 35.15, y: 26.79), controlPoint2: batPoint(x: 34.91, y: 26.49))
        superletterPath.addCurve(to: batPoint(x: 33.55, y: 25.74), controlPoint1: batPoint(x: 34.3, y: 26.02), controlPoint2: batPoint(x: 33.95, y: 25.85))
        superletterPath.addCurve(to: batPoint(x: 32.24, y: 25.57), controlPoint1: batPoint(x: 33.14, y: 25.63), controlPoint2: batPoint(x: 32.71, y: 25.57))
        superletterPath.addCurve(to: batPoint(x: 31.01, y: 25.73), controlPoint1: batPoint(x: 31.82, y: 25.57), controlPoint2: batPoint(x: 31.41, y: 25.63))
        superletterPath.addCurve(to: batPoint(x: 29.95, y: 26.21), controlPoint1: batPoint(x: 30.61, y: 25.84), controlPoint2: batPoint(x: 30.26, y: 26))
        superletterPath.addCurve(to: batPoint(x: 29.19, y: 27.03), controlPoint1: batPoint(x: 29.63, y: 26.42), controlPoint2: batPoint(x: 29.38, y: 26.7))
        superletterPath.addCurve(to: batPoint(x: 28.91, y: 28.21), controlPoint1: batPoint(x: 29.01, y: 27.36), controlPoint2: batPoint(x: 28.91, y: 27.76))
        superletterPath.addCurve(to: batPoint(x: 29.16, y: 29.24), controlPoint1: batPoint(x: 28.91, y: 28.62), controlPoint2: batPoint(x: 28.99, y: 28.97))
        superletterPath.addCurve(to: batPoint(x: 29.83, y: 29.91), controlPoint1: batPoint(x: 29.33, y: 29.51), controlPoint2: batPoint(x: 29.55, y: 29.74))
        superletterPath.addCurve(to: batPoint(x: 30.77, y: 30.32), controlPoint1: batPoint(x: 30.11, y: 30.08), controlPoint2: batPoint(x: 30.42, y: 30.22))
        superletterPath.addCurve(to: batPoint(x: 31.85, y: 30.6), controlPoint1: batPoint(x: 31.12, y: 30.43), controlPoint2: batPoint(x: 31.48, y: 30.52))
        superletterPath.addCurve(to: batPoint(x: 32.92, y: 30.84), controlPoint1: batPoint(x: 32.21, y: 30.68), controlPoint2: batPoint(x: 32.57, y: 30.76))
        superletterPath.addCurve(to: batPoint(x: 33.86, y: 31.13), controlPoint1: batPoint(x: 33.27, y: 30.91), controlPoint2: batPoint(x: 33.58, y: 31.01))
        superletterPath.addCurve(to: batPoint(x: 34.53, y: 31.61), controlPoint1: batPoint(x: 34.14, y: 31.25), controlPoint2: batPoint(x: 34.36, y: 31.41))
        superletterPath.addCurve(to: batPoint(x: 34.78, y: 32.36), controlPoint1: batPoint(x: 34.7, y: 31.8), controlPoint2: batPoint(x: 34.78, y: 32.05))
        superletterPath.addCurve(to: batPoint(x: 34.57, y: 33.17), controlPoint1: batPoint(x: 34.78, y: 32.69), controlPoint2: batPoint(x: 34.71, y: 32.96))
        superletterPath.addCurve(to: batPoint(x: 34.04, y: 33.67), controlPoint1: batPoint(x: 34.44, y: 33.38), controlPoint2: batPoint(x: 34.26, y: 33.55))
        superletterPath.addCurve(to: batPoint(x: 33.28, y: 33.93), controlPoint1: batPoint(x: 33.81, y: 33.79), controlPoint2: batPoint(x: 33.56, y: 33.88))
        superletterPath.addCurve(to: batPoint(x: 32.46, y: 34), controlPoint1: batPoint(x: 33.01, y: 33.98), controlPoint2: batPoint(x: 32.73, y: 34))
        superletterPath.addCurve(to: batPoint(x: 31.45, y: 33.88), controlPoint1: batPoint(x: 32.11, y: 34), controlPoint2: batPoint(x: 31.78, y: 33.96))
        superletterPath.addCurve(to: batPoint(x: 30.6, y: 33.49), controlPoint1: batPoint(x: 31.13, y: 33.79), controlPoint2: batPoint(x: 30.84, y: 33.66))
        superletterPath.addCurve(to: batPoint(x: 30.01, y: 32.81), controlPoint1: batPoint(x: 30.36, y: 33.31), controlPoint2: batPoint(x: 30.16, y: 33.08))
        superletterPath.addCurve(to: batPoint(x: 29.78, y: 31.83), controlPoint1: batPoint(x: 29.86, y: 32.54), controlPoint2: batPoint(x: 29.78, y: 32.21))
        superletterPath.addLine(to: batPoint(x: 28.63, y: 31.83))
        superletterPath.addCurve(to: batPoint(x: 28.93, y: 33.25), controlPoint1: batPoint(x: 28.63, y: 32.38), controlPoint2: batPoint(x: 28.73, y: 32.85))
        superletterPath.addCurve(to: batPoint(x: 29.75, y: 34.24), controlPoint1: batPoint(x: 29.13, y: 33.65), controlPoint2: batPoint(x: 29.41, y: 33.98))
        superletterPath.addCurve(to: batPoint(x: 30.96, y: 34.81), controlPoint1: batPoint(x: 30.1, y: 34.49), controlPoint2: batPoint(x: 30.5, y: 34.68))
        superletterPath.addCurve(to: batPoint(x: 32.42, y: 35), controlPoint1: batPoint(x: 31.42, y: 34.94), controlPoint2: batPoint(x: 31.9, y: 35))
        superletterPath.addCurve(to: batPoint(x: 33.68, y: 34.85), controlPoint1: batPoint(x: 32.84, y: 35), controlPoint2: batPoint(x: 33.26, y: 34.95))
        superletterPath.addCurve(to: batPoint(x: 34.83, y: 34.39), controlPoint1: batPoint(x: 34.11, y: 34.76), controlPoint2: batPoint(x: 34.49, y: 34.6))
        superletterPath.addCurve(to: batPoint(x: 35.67, y: 33.56), controlPoint1: batPoint(x: 35.17, y: 34.17), controlPoint2: batPoint(x: 35.45, y: 33.9))
        superletterPath.addCurve(to: batPoint(x: 36, y: 32.32), controlPoint1: batPoint(x: 35.89, y: 33.21), controlPoint2: batPoint(x: 36, y: 32.8))
        superletterPath.addCurve(to: batPoint(x: 35.75, y: 31.21), controlPoint1: batPoint(x: 36, y: 31.88), controlPoint2: batPoint(x: 35.92, y: 31.51))
        superletterPath.addCurve(to: batPoint(x: 35.08, y: 30.48), controlPoint1: batPoint(x: 35.58, y: 30.92), controlPoint2: batPoint(x: 35.36, y: 30.68))
        superletterPath.addCurve(to: batPoint(x: 34.14, y: 30.02), controlPoint1: batPoint(x: 34.8, y: 30.29), controlPoint2: batPoint(x: 34.49, y: 30.14))
        superletterPath.addCurve(to: batPoint(x: 33.07, y: 29.72), controlPoint1: batPoint(x: 33.79, y: 29.91), controlPoint2: batPoint(x: 33.43, y: 29.81))
        superletterPath.addCurve(to: batPoint(x: 31.99, y: 29.49), controlPoint1: batPoint(x: 32.7, y: 29.64), controlPoint2: batPoint(x: 32.34, y: 29.56))
        superletterPath.addCurve(to: batPoint(x: 31.05, y: 29.22), controlPoint1: batPoint(x: 31.64, y: 29.42), controlPoint2: batPoint(x: 31.33, y: 29.33))
        superletterPath.addCurve(to: batPoint(x: 30.38, y: 28.8), controlPoint1: batPoint(x: 30.77, y: 29.11), controlPoint2: batPoint(x: 30.55, y: 28.97))
        superletterPath.addCurve(to: batPoint(x: 30.13, y: 28.12), controlPoint1: batPoint(x: 30.21, y: 28.62), controlPoint2: batPoint(x: 30.13, y: 28.4))
        superletterPath.addCurve(to: batPoint(x: 30.3, y: 27.38), controlPoint1: batPoint(x: 30.13, y: 27.83), controlPoint2: batPoint(x: 30.19, y: 27.58))
        superletterPath.addCurve(to: batPoint(x: 30.77, y: 26.91), controlPoint1: batPoint(x: 30.42, y: 27.19), controlPoint2: batPoint(x: 30.57, y: 27.03))
        superletterPath.addCurve(to: batPoint(x: 31.43, y: 26.66), controlPoint1: batPoint(x: 30.96, y: 26.79), controlPoint2: batPoint(x: 31.18, y: 26.71))
        superletterPath.addCurve(to: batPoint(x: 32.19, y: 26.58), controlPoint1: batPoint(x: 31.68, y: 26.61), controlPoint2: batPoint(x: 31.93, y: 26.58))
        superletterPath.addCurve(to: batPoint(x: 33.75, y: 27.02), controlPoint1: batPoint(x: 32.82, y: 26.58), controlPoint2: batPoint(x: 33.34, y: 26.73))
        superletterPath.addCurve(to: batPoint(x: 34.46, y: 28.43), controlPoint1: batPoint(x: 34.15, y: 27.31), controlPoint2: batPoint(x: 34.39, y: 27.78))
        superletterPath.close()
        return superletterPath.cgPath
    }
    
}
