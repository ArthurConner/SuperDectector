//: Playground - noun: a place where people can play

import UIKit

var str = "Hello, playground"

func dist(_ a:CGPoint, _ b:CGPoint)->CGFloat{
    return (a.x-b.x) * (a.x-b.x) +  (a.y-b.y) * (a.y-b.y)
}

func ave(_ a:CGPoint, _ b:CGPoint)->CGPoint{
    return CGPoint(x: (a.x + b.y)/2.0, y: (a.y + b.y)/2.0)
}


func slope(_ a:CGPoint, _ b:CGPoint)->CGFloat{
    if a.x != b.x {
       return (a.y - b.y)/(a.x  - b.x)
    }
    
    return 0
}

let lefteye = CGPoint(x:10,y:20)
let righteye = CGPoint(x:40,y:50)
let mideye = ave(lefteye,righteye)

let leftmouth = CGPoint(x:10,y:40)
let rightmouth = CGPoint(x:40,y:40)
let midmouth = ave(leftmouth,rightmouth)

let eyeslope = slope(lefteye,righteye)

var transform = CGAffineTransform(translationX: -mideye.x, y: -mideye.y)

let ang = atan(eyeslope)
let deg = ang / CGFloat.pi * 100

transform = transform.concatenating(CGAffineTransform(rotationAngle: ang))
transform = transform.concatenating(CGAffineTransform(translationX: mideye.x, y: mideye.y))

let p = midmouth.applying(transform)
let lprine = leftmouth.applying(transform)
let rprine = rightmouth.applying(transform)

let ls = slope(lprine,rprine)
let rs = slope(lefteye, righteye)
let d = dist(lprine, rprine) - dist(leftmouth,rightmouth)





