//
//  Action+Util.swift
//  QuickTest
//
//  Created by Nicolas Nascimento on 5/4/16.
//  Copyright © 2016 LastLeaf. All rights reserved.
//

import GameKit

/// The direction that a rotation can follow
enum RotationType {
    case clockwise
    case counterClockwise
}

extension SKAction {
    
    /** Creates an action that resize font size of a SKLabelNode using the provided scaling factor.
     @param originalFontSize The originalFontSize
     @param scalingFactor The scaling factor (multiplier for the original font size)
     @param duration The lasting of the action
     */
    class func resizeFontSizeWithOriginalFontSize(_ originalFontSize: CGFloat, scalingFactor: CGFloat, duration: Double) -> SKAction {
        let targetFontSize = originalFontSize*scalingFactor
        let deltaFontSize = targetFontSize - originalFontSize
        return SKAction.customAction(withDuration: duration) { (node: SKNode, elapsedTime: CGFloat) in
            if let labelNode = node as? SKLabelNode {
                let fractionalTime = elapsedTime/CGFloat(duration)
                let currentFontSize = originalFontSize + deltaFontSize*(fractionalTime)
                labelNode.fontSize = currentFontSize
            }
        }
    }
    /** Creates an action that rotates a node around an arbitray point with a given radius.
     @param radius The radius for the rotation
     @param centerPoint The anchor point to be used for the rotation
     @param duration The lasting of the action
     @param startingTime A value that should range from 0 to duration, it'll be used to calculate the starting position
     @param rotationType An enum that tells the direction that the rotation will follow
     */
    class func rotateAroundRadius(_ radius: CGFloat, centerPoint: CGPoint, withDuration duration: Double, startingTime: CGFloat, rotationType: RotationType = .counterClockwise) -> SKAction {
        let multiplier = rotationType == .counterClockwise ? 1.0 : -1.0
        return SKAction.customAction(withDuration: duration) { (node, elapsedTime) -> Void in
            
            let fractionalTime = (duration - (duration - Double(elapsedTime + startingTime)))/duration
            node.position.x = centerPoint.x + CGFloat(Double(radius)*cos(2*M_PI*fractionalTime))            // cos(-x) = cos(x)
            node.position.y = centerPoint.y + CGFloat(Double(radius)*sin(2*M_PI*fractionalTime)*multiplier) // sin(-x) = -sin(x)
        }
    }
    /** Creates an action that moves a node to an given point, proving a bounce effect.
     @param initialPosition The initial position for the node
     @param newPosition The new position for the node
     @param totalDuration The lasting of the action
     @param maximumBounceRatio The farther away an object can go before bouncing back. 0 means no bounce, 1 means the full distance between the original location and the new position will be used for the first bounce
     */
    class func bounceMoveFromPosition(_ initialPosition: CGPoint, ToPosition newPosition: CGPoint, maximumBounceRatio: CGFloat, totalDuration: Double) ->SKAction {
        
        // Direction
        let stabilizationTime: CGFloat = CGFloat(totalDuration)*0.8 // This assures stabilizaition will be reached
        let directionVector: CGVector = CGVector(dx: newPosition.x - initialPosition.x, dy: newPosition.y - initialPosition.y)
        let totalGain = directionVector.module()
        let xPositionTransferFunction = TransferFunction(gain: totalGain*cos(directionVector.angle()), overshot: maximumBounceRatio, stabilizationTime: stabilizationTime)
        let yPositionTransferFunction = TransferFunction(gain: totalGain*sin(directionVector.angle()), overshot: maximumBounceRatio, stabilizationTime: stabilizationTime)
        
        return SKAction.customAction(withDuration: totalDuration) { (node, elapsedTime) in
            //let delta = elapsedTime - lastTime
            if( elapsedTime == CGFloat(totalDuration) ) {
                node.position = newPosition
            }else{
                let lastXValue = xPositionTransferFunction.lastEvaluatedValue
                let lastYValue = yPositionTransferFunction.lastEvaluatedValue
                
                node.position.x += (xPositionTransferFunction.evaluateFunctionAtTime(elapsedTime) - lastXValue)//= initialPosition.x + xPositionTransferFunction.evaluateFunctionAtTime(elapsedTime)
                node.position.y += (yPositionTransferFunction.evaluateFunctionAtTime(elapsedTime) - lastYValue)//= initialPosition.y + yPositionTransferFunction.evaluateFunctionAtTime(elapsedTime)
            }
        }
    }
    /** Creates an action that moves a node to an given point, proving a smoothing effect.
     @param initialPosition The initial position for the node
     @param newPosition The new position for the node
     @param totalDuration The lasting of the action
     @param assuresFinalPosition indicates wheter the final position should be the final point of the action
     */
    class func smoothMoveFromPosition(_ initialPosition: CGPoint, ToPosition newPosition: CGPoint, totalDuration: Double, assuresFinalPosition: Bool = true) ->SKAction {
        
        // Direction
        let stabilizationTime: CGFloat = CGFloat(totalDuration) // This assures stabilizaition will be reached
        let directionVector: CGVector = CGVector(dx: newPosition.x - initialPosition.x, dy: newPosition.y - initialPosition.y)
        let totalGain = directionVector.module()
        let xPositionTransferFunction = TransferFunction(gain: totalGain*cos(directionVector.angle()), stabilizationTime: stabilizationTime)
        let yPositionTransferFunction = TransferFunction(gain: totalGain*sin(directionVector.angle()), stabilizationTime: stabilizationTime)
        
        return SKAction.customAction(withDuration: totalDuration) { (node, elapsedTime) in
            //let delta = elapsedTime - lastTime
            if( elapsedTime == CGFloat(totalDuration) && assuresFinalPosition ) {
                node.position = newPosition
            }else{
                let lastXValue = xPositionTransferFunction.lastEvaluatedValue
                let lastYValue = yPositionTransferFunction.lastEvaluatedValue
                node.position.x += (xPositionTransferFunction.evaluateFunctionAtTime(elapsedTime) - lastXValue)//= initialPosition.x + xPositionTransferFunction.evaluateFunctionAtTime(elapsedTime)
                node.position.y += (yPositionTransferFunction.evaluateFunctionAtTime(elapsedTime) - lastYValue)//= initialPosition.y + yPositionTransferFunction.evaluateFunctionAtTime(elapsedTime)
            }
        }
    }
    /** Creates an action that scales(x and y) a node to a given scale proving a bounce effect.
     @param initialScale The initial scale for the node
     @param newScale The new scale for the node
     @param totalDuration The lasting of the action
     @param maximumBounceRatio The farthest a scale can go before bouncing back. 0 means no bounce, 1 means the full scaling.
     */
    class func bounceScaleFrom(_ initialScale: CGFloat, ToScale newScale: CGFloat, maximumBounceRatio: CGFloat, totalDuration: Double) -> SKAction {
        let totalGain = newScale - initialScale
        let scaleTransferFunction = TransferFunction(gain: totalGain, overshot: maximumBounceRatio, stabilizationTime: CGFloat(totalDuration*0.8))
        
        return SKAction.customAction(withDuration: totalDuration) { (node, elapsedTime) in
            if( elapsedTime == CGFloat(totalDuration) ) {
                node.setScale(newScale)
            }else{
                let scale = initialScale + scaleTransferFunction.evaluateFunctionAtTime(elapsedTime)
                node.setScale(scale)
            }
        }
    }
}

extension CGVector {
    /// the angle for the vector in radians
    func angle() -> CGFloat {
        return atan2(self.dy, self.dx)
    }
    /// The module for the vector
    func module() -> CGFloat {
        return sqrt((self.dx*self.dx) + (self.dy*self.dy))
    }
    /// The normalized version of this vector
    func normalized() -> CGVector {
        let module = self.module()
        if( (self.dx == 0 && self.dy == 0 ) || module < 1.0 ) {
            return self
        }
        return CGVector(dx: self.dx/module, dy: self.dy/module)
    }
}

extension CGPoint {
    /// Pythagorean Theorem
    func distanceToPoint( _ point: CGPoint) -> CGFloat{
        let deltaX = self.x - point.x
        let deltaY = self.y - point.y
        return sqrt((deltaX*deltaX) + (deltaY*deltaY))
    }
}


