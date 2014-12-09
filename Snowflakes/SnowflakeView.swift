//
//  SnowflakeView.swift
//  Snowflakes
//
//  Created by Austin Younts on 12/8/14.
//  Copyright (c) 2014 Greenville Cocoaheads. All rights reserved.
//

import UIKit

func degree2radian(a:CGFloat)->CGFloat {
    let b = CGFloat(M_PI) * a/180
    return b
}

class SnowflakeView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.clearColor()
    }


    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func drawRect(rect: CGRect) {
        
        let polygonSides = Int(arc4random_uniform(3) + 5)
        
        drawPolygonBezier(rect: rect, scaleFactor: 3, sides: polygonSides, color: UIColor.whiteColor())
        drawPolygonBezier(rect: rect, scaleFactor: 2, sides: polygonSides, color: UIColor.whiteColor())
        
        drawTicTacToeBezier(rect: rect, scaleFactor: 2, color: UIColor.whiteColor(), angle: 0)
        drawTicTacToeBezier(rect: rect, scaleFactor: 2, color: UIColor.whiteColor(), angle: 45)
        
        let numberOfTrees = arc4random_uniform(5) + 5
        for i in 0..<numberOfTrees {
            let angle = (360 / numberOfTrees) * i
            drawTreeBezier(rect: rect, angle: CGFloat(angle), color: UIColor.whiteColor())
        }
    }
    
    func insetRect(rect: CGRect, byFactor: Int) -> CGRect {
        let xInset = (CGRectGetWidth(rect) - (CGRectGetWidth(rect) / CGFloat(byFactor))) / 2
        let yInset = (CGRectGetWidth(rect) - (CGRectGetHeight(rect) / CGFloat(byFactor))) / 2
        return CGRectInset(rect, xInset, yInset)
    }
    
    // MARK: Tree
    
    func drawTreeBezier(#rect: CGRect, #angle: CGFloat, #color: UIColor) {
        
        let path = UIBezierPath()
        
        let startingDistance = CGRectGetWidth(rect) / 6
        
        let branchAngle = arc4random_uniform(20) + 15
        
        let centerPoint = CGPointMake(0, 0)
        let startingPoint = point(centerPoint, distance: startingDistance, angle: angle)
        let endingPoint = point(startingPoint, distance: startingDistance * 2, angle: angle)
        
        let branchStartingPointPercentages = [1.2, 1.5]
        var branchStartingPoints: [CGPoint] = []
        for i in branchStartingPointPercentages {
            branchStartingPoints.append(point(startingPoint, distance: startingDistance * CGFloat(i), angle: angle))
        }
        
        for i in branchStartingPoints {
            path.moveToPoint(i)
            let branchLength: CGFloat = (CGFloat(arc4random_uniform(45) + 5)) / 100.0
            path.addLineToPoint(point(i, distance: startingDistance / CGFloat(branchLength), angle: angle + CGFloat(branchAngle)))
            
            path.moveToPoint(i)
            path.addLineToPoint(point(i, distance: startingDistance / CGFloat(branchLength), angle: angle - CGFloat(branchAngle)))
        }
        
        path.moveToPoint(centerPoint)
        path.moveToPoint(startingPoint)
        path.addLineToPoint(endingPoint)
        
        path.applyTransform(CGAffineTransformMakeTranslation(CGRectGetMidX(rect), CGRectGetMidY(rect)))
        
        color.setStroke()
        path.stroke()
    }
    
    func point(startingPoint: CGPoint, distance: CGFloat, angle: CGFloat) -> CGPoint {
        let y = distance * sin(degree2radian(angle))
        let x = distance * cos(degree2radian(angle))
        return CGPointMake(x, y)
    }
    
    // MARK: TicTacToe
    
    func drawTicTacToeBezier(#rect: CGRect, #scaleFactor: Int, #color: UIColor, #angle: CGFloat) {
        
        let drawRect = insetRect(rect, byFactor: scaleFactor)
        
        let offsetX = (CGRectGetWidth(rect) - CGRectGetWidth(drawRect)) / 2
        let offsetY = (CGRectGetHeight(rect) - CGRectGetHeight(drawRect)) / 2
        
        let xPoints = pointsForTicTacToeLines(CGRectGetWidth(drawRect), offset: offsetX)
        let yPoints = pointsForTicTacToeLines(CGRectGetHeight(drawRect), offset: offsetY)
        
        let path = UIBezierPath()
        
        for point in xPoints {
            path.moveToPoint(CGPointMake(point, CGRectGetMinY(drawRect)))
            path.addLineToPoint(CGPointMake(point, CGRectGetMaxX(drawRect)))
        }
        
        for point in yPoints {
            path.moveToPoint(CGPointMake(CGRectGetMinX(drawRect), point))
            path.addLineToPoint(CGPointMake(CGRectGetMaxX(drawRect), point))
        }
        
        let insetDifference = CGRectGetWidth(rect) / 2
        path.applyTransform(CGAffineTransformMakeTranslation(-insetDifference, -insetDifference))
        path.applyTransform(CGAffineTransformMakeRotation(degree2radian(angle)))
        path.applyTransform(CGAffineTransformMakeTranslation(insetDifference, insetDifference))
        
        let strokeWidth = CGFloat(CGFloat(arc4random_uniform(300)) / 100.0)
        
        path.lineWidth = strokeWidth
        
        color.setStroke()
        path.stroke()
        
    }
    
    func pointsForTicTacToeLines(length: CGFloat, offset: CGFloat) -> [CGFloat] {
        let firstPercent = CGFloat(0.4)
        let secondPercent = CGFloat(0.6)
        return [(length * firstPercent) + offset, (length * secondPercent) + offset]
    }
    
    // MARK: Polygons
    
    func polygonPointArray(sides: Int, x:CGFloat, y: CGFloat, radius: CGFloat) -> [CGPoint] {
        let angle = degree2radian(360/CGFloat(sides))
        let cx = x // x origin
        let cy = y // y origin
        let r  = radius // radius of circle
        var i = 0
        var points = [CGPoint]()
        while i <= sides {
            var xpo = cx + r * cos(angle * CGFloat(i))
            var ypo = cy + r * sin(angle * CGFloat(i))
            points.append(CGPoint(x: xpo, y: ypo))
            i++;
        }
        return points
    }
   
    func drawPolygonBezier(#rect: CGRect, #scaleFactor: Int, #sides: Int, #color: UIColor) {
        
        let drawRect = insetRect(rect, byFactor: scaleFactor)
        
        let points = polygonPointArray(sides, x: CGRectGetMidX(drawRect), y: CGRectGetMidY(drawRect), radius: CGRectGetWidth(drawRect) / 2)
        
        let path = UIBezierPath()
        
        path.moveToPoint(points.first!)
        
        for point in points {
            path.addLineToPoint(point)
        }
        
        color.setStroke()
        
        path.stroke()
    }
}
