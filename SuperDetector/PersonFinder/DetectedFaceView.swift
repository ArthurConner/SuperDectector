//
//  DetectedFaceView.swift
//  SuperDetector
//
//  Created by Arthur  on 8/28/17.
//  Copyright © 2017 Arthur . All rights reserved.
//

import UIKit
import Vision

class DetectedFaceView: UIImageView {
    
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */
    
    
    var heroIndex = -1
    
    var face:VNFaceObservation?
    var useImage = false
    var currentSettings = DimensionSetting()
    
    func hero ()->CharacterSpec? {
        
        let cast = CharacterSpec.makeCast()
        guard heroIndex >= 0 && heroIndex < cast.count else { return nil }
        let (_,builder) =  cast[heroIndex]
        return builder(nil, currentSettings)
        
    }
    
    func load(index :Int){
        
        heroIndex = index
        
        
        if useImage {
            if let hero = self.hero() {
                self.image = hero.image()
            } else {
                self.backgroundColor = .red
            }
            
        } else {
            self.backgroundColor = .clear
        }
        self.contentMode = .scaleAspectFit
        
        
    }
    
    func disable(){
        self.alpha = 0
        self.frame = CGRect(x: 0, y: 0, width: 1, height: 1)
        
        if let la = self.layer.sublayers {
            for x in la {
                x.removeFromSuperlayer()
            }
        }
    }
    
    func enable(detected:VNFaceObservation){
        
        self.alpha = 1
        self.face = detected
        let c = detected.boundingBox
        
        if let la = self.layer.sublayers {
            for x in la {
                x.removeFromSuperlayer()
            }
        }
        
        if let sup = self.superview {
            let p = sup.bounds.size
            let b = CGRect(x: c.minX * p.width, y: p.height - (c.minY + c.height)  * p.height, width: c.width * p.width, height: c.height * p.height)
            
            if useImage {
                let scale:CGFloat = 1.5
                let nextW = scale * b.width
                let nextH = scale * b.height
                let xoff = b.minX - (nextW - b.width)/2
                let yoff = b.minY - (nextH )/3
                
                self.frame = CGRect(x: xoff, y: yoff, width: nextW, height: nextH)
            } else {
                self.frame = b
            }
            
            makeLayers(face: detected)
            
            // detectLandmarks(detected)
        }
        
    }
    
    
    func detectLandmarks(_ observation:VNFaceObservation) {
        
        guard let her = self.hero() else {
            return
        }
        let faceBoundingBox = self.frame
        
        //different types of landmarks
        // let faceContour = observation.landmarks?.faceContour
        //self.convertPointsForFace(faceContour, faceBoundingBox, her.skin.cgColor)
        
        let leftEye = observation.landmarks?.leftEye
        self.drawLandmark(leftEye, faceBoundingBox, UIColor.white.cgColor)
        
        let rightEye = observation.landmarks?.rightEye
        self.drawLandmark(rightEye, faceBoundingBox, UIColor.white.cgColor)
        
        let nose = observation.landmarks?.nose
        self.drawLandmark(nose, faceBoundingBox,her.skin.cgColor)
        
        let lips = observation.landmarks?.innerLips
        self.drawLandmark(lips, faceBoundingBox, UIColor.red.cgColor)
        
        let leftEyebrow = observation.landmarks?.leftEyebrow
        self.drawLandmark(leftEyebrow, faceBoundingBox, (her.hair ?? .black).cgColor)
        
        let rightEyebrow = observation.landmarks?.rightEyebrow
        self.drawLandmark(rightEyebrow, faceBoundingBox,(her.hair ?? .black).cgColor)
        
        let noseCrest = observation.landmarks?.noseCrest
        self.drawLandmark(noseCrest, faceBoundingBox, her.skin.cgColor)
        
        let outerLips = observation.landmarks?.outerLips
        self.drawLandmark(outerLips, faceBoundingBox, UIColor.red.cgColor)
        
        
        
    }
    
    
    func pointsForFace(_ landmark: VNFaceLandmarkRegion2D?, _ boundingBox: CGRect ) -> [CGPoint] {
        
        guard let mark = landmark else { return [] }
        let points:[CGPoint] = mark.normalizedPoints
        
        let topSize = self.frame.size
        
        guard !(points.isEmpty) else { return  []}
        
        let convertedPoints:[CGPoint] = points.map{
            let b = CGPoint(x: topSize.width * ($0.x ), y: topSize.height * (1 - $0.y))
            return b
        }
        
        return convertedPoints
        //self.draw(points:convertedPoints, color:color)
        
    }
    

    
    func centerOf( landmark: VNFaceLandmarkRegion2D?, _ boundingBox: CGRect)->CGPoint?{
        
        let convertedPoints = pointsForFace(landmark, boundingBox)
        
        guard !convertedPoints.isEmpty else { return nil }
        let fcount:CGFloat = CGFloat(convertedPoints.count)
        
        let sum = convertedPoints.reduce(CGPoint.zero, {CGPoint(x:$0.x + $1.x,y:$0.y + $1.y)})
        let center = CGPoint(x: sum.x/fcount, y: sum.y/fcount)
        return center
    }
    
    func drawCenter(_ landmark: VNFaceLandmarkRegion2D?, _ boundingBox: CGRect, _ color:CGColor ) {
        
        let convertedPoints = pointsForFace(landmark, boundingBox)
        guard !convertedPoints.isEmpty else { return }
        guard let centerFace = self.centerOf(landmark:landmark, boundingBox) else {return}
        
        let ys = convertedPoints.map{return $0.y}
        let xs = convertedPoints.map{return $0.x}
        
        if let ymax = ys.max(), let ymin =  ys.min(), let  xmax = xs.max() , let xmin = xs.min()
            
        {
            let radius = min(ymax-ymin,xmax-xmin) * 0.85
            let newShape = CAShapeLayer()
            newShape.path = UIBezierPath(arcCenter: centerFace, radius: radius/2, startAngle: 0, endAngle: CGFloat.pi * 2, clockwise: true).cgPath
            newShape.fillColor = color
            self.layer.addSublayer(newShape)
        }
        
        
        
        
    }
    
    
    func drawLandmark(_ landmark: VNFaceLandmarkRegion2D?, _ boundingBox: CGRect, _ color:CGColor ) {
        
        let convertedPoints = pointsForFace(landmark, boundingBox)
        guard !convertedPoints.isEmpty else { return }
        self.draw(points:convertedPoints, color:color)
        
    }
    
    func draw(points: [CGPoint],color:CGColor ) {
        let newLayer = CAShapeLayer()
        newLayer.strokeColor = UIColor.black.cgColor
        newLayer.lineWidth = 1.0
        newLayer.fillColor = color
        let path = UIBezierPath()
        
        guard let firstPoint = points.first else { return }
        
        path.move(to: firstPoint)
        for i in 0..<points.count - 1 {
            let point = points[i+1]
            path.addLine(to: point)
        }
        path.addLine(to: firstPoint)
        path.close()
        newLayer.path = path.cgPath
        
        self.layer.addSublayer(newLayer)
    }
    
    
    
    
}

extension DetectedFaceView {
    
    
    /*
     func makeFace() ->CGPath{
     let facePath = UIBezierPath()
     facePath.move(to: batPoint(x: 59.81, y: 44))
     facePath.addCurve(to: batPoint(x: 32, y: 74), controlPoint1: batPoint(x: 58.18, y: 60.89), controlPoint2: batPoint(x: 46.35, y: 74))
     facePath.addCurve(to: batPoint(x: 4.19, y: 44), controlPoint1: batPoint(x: 17.65, y: 74), controlPoint2: batPoint(x: 5.82, y: 60.89))
     facePath.addLine(to: batPoint(x: 59.81, y: 44))
     facePath.close()
     return facePath.cgPath
     }
     */
    
    func makeLayers(face:VNFaceObservation){
        
        
        let faceBoundingBox = self.frame
        let yjust:CGFloat = 1.2
        let scaleX  = faceBoundingBox.size.width / 60.0
        let scaleY = faceBoundingBox.size.height / 75.0 * yjust
        
        self.currentSettings.normalize()
        
        self.currentSettings.scaleX *= scaleX
        self.currentSettings.scaleY *= scaleY
        self.currentSettings.yOff = +20
        
        // let newy = scaleY * ((2*yOff) - (2 * y))
        
        let leftEye = face.landmarks?.leftEye
        let rightEye = face.landmarks?.rightEye
        
        if let leftEyeCent = centerOf(landmark: leftEye, faceBoundingBox),
        let rightEyeCent = centerOf(landmark: rightEye, faceBoundingBox),
            leftEyeCent.x != rightEyeCent.x {
            
            let eyeslope =  (leftEyeCent.y - rightEyeCent.y)/(leftEyeCent.x  - rightEyeCent.x)
            let ang = atan(eyeslope)
            
            
            let mideye = self.currentSettings.point(x:(10.0+41.0)/2,y:33.0)
            var transform = CGAffineTransform(translationX: -mideye.x, y: -mideye.y)
            transform = transform.concatenating(CGAffineTransform(rotationAngle: ang))
            transform = transform.concatenating(CGAffineTransform(translationX: mideye.x, y: mideye.y))
            self.currentSettings.transform = transform
        }
        
        
        
        //-faceBoundingBox.size.height * (yjust - 1)
        // self.currentSettings.yOff   *= 1/(2*yjust)
        
        guard let spec = self.hero() else { return }
        
        
        let b = spec.headMaker
        let head = CAShapeLayer()
        head.fillColor = spec.mask.cgColor
        head.path = b()
        self.layer.addSublayer(head)
        
        if let f  = spec.faceMaker {
            let p = f()
            //print("\(p)")
            
            let newLayer = CAShapeLayer()
            newLayer.fillColor = spec.skin.cgColor
            newLayer.lineWidth = 1.0
            
            newLayer.path = p
            self.layer.addSublayer(newLayer)
            
        }
        
        
        
        for f in spec.nodeMakers {
            let (_,fill,stroke,pathM) = f()
            let newLayer = CAShapeLayer()
            newLayer.fillColor = fill.cgColor
            newLayer.strokeColor = stroke?.cgColor
            
            newLayer.path = pathM()
            self.layer.addSublayer(newLayer)
            
            
        }
        
        self.drawLandmark(leftEye, faceBoundingBox, UIColor.white.cgColor)
        self.drawCenter(leftEye, faceBoundingBox, UIColor.black.cgColor)
        
        
        self.drawLandmark(rightEye, faceBoundingBox, UIColor.white.cgColor)
        self.drawCenter(rightEye, faceBoundingBox, UIColor.black.cgColor)
        
        
        let leftEyebrow = face.landmarks?.leftEyebrow
        self.drawLandmark(leftEyebrow, faceBoundingBox, (spec.hair ?? .black).cgColor)
        
        let rightEyebrow = face.landmarks?.rightEyebrow
        self.drawLandmark(rightEyebrow, faceBoundingBox,(spec.hair ?? .black).cgColor)
        
        
        
        let outerLips = face.landmarks?.outerLips
        self.drawLandmark(outerLips, faceBoundingBox, UIColor.red.cgColor)
        
        let nose = face.landmarks?.nose
        self.drawLandmark(nose, faceBoundingBox,UIColor.clear.cgColor)
        
        let lips = face.landmarks?.innerLips
        self.drawLandmark(lips, faceBoundingBox, UIColor.white.cgColor)
        
        
    }
    
    
    
}

