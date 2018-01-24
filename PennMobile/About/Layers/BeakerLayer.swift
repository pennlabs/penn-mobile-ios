//
//  BeakerLayer.swift
//  PennMobile
//
//  Created by Dominic Holmes on 12/31/17.
//  Copyright © 2017 PennLabs. All rights reserved.
//

import UIKit

class BeakerLayer: CAShapeLayer {
    
    struct Beaker {
        // compressionRatio: 100.0 / 751.0
        static let w: CGFloat = 304.0 * (100.0 / 751.0) // width
        static let h: CGFloat = 350.0 * (100.0 / 751.0) // height
        static let x: CGFloat = 208.0 * (100.0 / 751.0) // starting x
        static let y: CGFloat = 260.0 * (100.0 / 751.0) // starting y
        static let r: CGFloat = 20.0 * (100.0 / 751.0)  // radius
        
        // space between top of beaker and water
        //static let waterOffset: CGFloat = 74.0 * (100.0 / 751.0)
        static let waterOffset: CGFloat = 0.0 * (100.0 / 751.0)
    }
    
    override init() {
        super.init()
        let labsBlue = UIColor(r: 41, g: 128, b: 185)
        fillColor = labsBlue.cgColor
        strokeColor = labsBlue.cgColor
        lineWidth = 2.0
        lineCap = kCALineCapRound
        lineJoin = kCALineJoinRound
        self.path = getBeakerPath(with: CGPoint(x: 0, y: 0))
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var waterPath: UIBezierPath?
    var controlPoint: CGPoint = CGPoint(x: 0, y: 0)
    
    
    func getBeakerPath(with pullpoint: CGPoint) -> CGPath {
        let outline = getWaterOutlinePath()
        outline.append(getWaterPath(with: pullpoint))
        return outline.cgPath
    }
    
    func getWaterOutlinePath() -> UIBezierPath {
        let beakerPath = UIBezierPath()
        
        beakerPath.move(to: CGPoint(x: Beaker.x,y: Beaker.y + Beaker.waterOffset))
        // Left edge
        beakerPath.addLine(to: CGPoint(x: Beaker.x,
                                       y: Beaker.y + Beaker.h - Beaker.r))
        // Bottom left corner
        beakerPath.addArc(withCenter: CGPoint(x: Beaker.x + Beaker.r,
                                              y: Beaker.y + Beaker.h - Beaker.r),
                          radius: Beaker.r,
                          startAngle: CGFloat.pi, endAngle: CGFloat.pi * 0.5,
                          clockwise: false)
        // Bottom edge
        beakerPath.addLine(to: CGPoint(x: Beaker.x + Beaker.w - Beaker.r,
                                       y: Beaker.y + Beaker.h))
        // Bottom right corner
        beakerPath.addArc(withCenter: CGPoint(x: Beaker.x + Beaker.w - Beaker.r,
                                              y: Beaker.y + Beaker.h - Beaker.r),
                          radius: Beaker.r,
                          startAngle: CGFloat.pi * 0.5, endAngle: 0.0,
                          clockwise: false)
        // Right edge
        beakerPath.addLine(to: CGPoint(x: Beaker.x + Beaker.w,
                                       y: Beaker.y + Beaker.waterOffset))
        return beakerPath
    }
    
    func getWaterPath(with pullPoint: CGPoint) -> UIBezierPath {
        let beakerPath = UIBezierPath()
        beakerPath.move(to: CGPoint(x: Beaker.x + Beaker.w, y: Beaker.y + Beaker.waterOffset))
        
        // Top edge, varies with pan gesture
        var xOffset = pullPoint.x // 3.0
        var yOffset = pullPoint.y // 3.0
        if (xOffset > 20.0 || xOffset < -20.0) {
            if xOffset < 0 {
                xOffset = -20.0
            } else {
                xOffset = 20.0
            }
        }
        if (yOffset > 20.0 || yOffset < -20.0) {
            if yOffset < 0 {
                yOffset = -20.0
            } else {
                yOffset = 20.0
            }
        }
        
        beakerPath.addQuadCurve(to: CGPoint(x: Beaker.x, y: Beaker.y + Beaker.waterOffset),
                                controlPoint: CGPoint(
                                    x: xOffset + Beaker.x + Beaker.w * 0.5,
                                    y: yOffset + Beaker.y + Beaker.waterOffset))
        return beakerPath
    }
    
    func getGlassEdges() -> UIBezierPath {
        let beakerPath = UIBezierPath()
        
        beakerPath.move(to: CGPoint(x: Beaker.x,y: Beaker.y))
        // Left edge
        beakerPath.addLine(to: CGPoint(x: Beaker.x,
                                       y: Beaker.y + Beaker.h - Beaker.r))
        // Bottom left corner
        beakerPath.addArc(withCenter: CGPoint(x: Beaker.x + Beaker.r,
                                              y: Beaker.y + Beaker.h - Beaker.r),
                          radius: Beaker.r,
                          startAngle: CGFloat.pi, endAngle: CGFloat.pi * 0.5,
                          clockwise: false)
        // Bottom edge
        beakerPath.addLine(to: CGPoint(x: Beaker.x + Beaker.w - Beaker.r,
                                       y: Beaker.y + Beaker.h))
        // Bottom right corner
        beakerPath.addArc(withCenter: CGPoint(x: Beaker.x + Beaker.w - Beaker.r,
                                              y: Beaker.y + Beaker.h - Beaker.r),
                          radius: Beaker.r,
                          startAngle: CGFloat.pi * 0.5, endAngle: 0.0,
                          clockwise: false)
        // Right edge
        beakerPath.addLine(to: CGPoint(x: Beaker.x + Beaker.w,
                                       y: Beaker.y))
        return beakerPath
    }
    
    func getGlassShapeLayer() -> CAShapeLayer {
        let beakerEdges = CAShapeLayer()
        beakerEdges.fillColor = UIColor.clear.cgColor
        let labsBlue = UIColor(r: 41, g: 128, b: 185)
        beakerEdges.strokeColor = labsBlue.cgColor
        beakerEdges.lineWidth = 2.0
        beakerEdges.lineCap = kCALineCapRound
        beakerEdges.lineJoin = kCALineJoinRound
        beakerEdges.path = getGlassEdges().cgPath
        return beakerEdges
    }
    
    // Emitter layer
    func createParticles() -> CAEmitterLayer {
        let particleEmitter = CAEmitterLayer()
        
        particleEmitter.emitterPosition = CGPoint(x: Beaker.x + Beaker.w * 0.5,
                                                  y: Beaker.y + Beaker.h - 2)
        particleEmitter.emitterShape = kCAEmitterLayerLine
        particleEmitter.emitterSize = CGSize(width: Beaker.w * 0.9, height: 1)
        
        let blue = makeBubbleEmitterCell()
        
        particleEmitter.emitterCells = [blue]
        
        return particleEmitter
    }
    
    func makeBubbleEmitterCell() -> CAEmitterCell {
        let cell = CAEmitterCell()
        
        // Big chill bubble friends
        
        /*
         cell.birthRate = 9
         cell.lifetime = 2.0
         cell.lifetimeRange = 0
         cell.velocity = 35
         cell.velocityRange = 20
         cell.emissionLongitude = 0.0
         cell.emissionRange = 0.0
         cell.scaleRange = 0.01
         cell.contents = UIImage(named: "bubble")?.cgImage
         cell.scale = 0.017*/
        
        /*
         // Big bubble friends
         cell.birthRate = 15
         cell.lifetime = 1.3
         cell.lifetimeRange = 0
         cell.velocity = 60
         cell.velocityRange = 20
         cell.emissionLongitude = 0.0
         cell.emissionRange = 0.0
         cell.scaleRange = 0.01
         cell.contents = UIImage(named: "bubble")?.cgImage
         cell.scale = 0.02
         */
        
        // Smol bubble friends
        cell.birthRate = 30
        cell.lifetime = 1.3
        cell.lifetimeRange = 0
        cell.velocity = 60
        cell.velocityRange = 20
        cell.emissionLongitude = 0.0
        cell.emissionRange = 0.0
        cell.scaleRange = 0.01
        cell.contents = UIImage(named: "bubble")?.cgImage
        cell.scale = 0.005
        
        
        return cell
    }
}
