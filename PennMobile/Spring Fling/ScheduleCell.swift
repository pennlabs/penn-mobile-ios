//
//  ScheduleCell.swift
//  PennMobile
//
//  Created by Zhilei Zheng on 4/8/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//

import UIKit

class ScheduleCell: UITableViewCell {

    var performerNameLabel = UILabel()
    var performerDescLabel = UILabel()
    
    var lineLayer:CALayer = CALayer()
    
    fileprivate var navigationBlue = UIColor(r: 74, g: 144, b: 226)
    fileprivate var dataGreen = UIColor(r: 118, g: 191, b: 150)
    
    func setUpView(for performer: FlingPerformer, isFirst:Bool) {
        self.clipsToBounds = true
        performerNameLabel.text = performer.name
        performerNameLabel.textColor = dataGreen
        performerNameLabel.font = UIFont(name: "AvenirNext-Medium", size: 19)
        performerDescLabel.text = getTimeString(for: performer)
        performerDescLabel.textColor = .black
        performerDescLabel.font = UIFont(name: "AvenirNext-Regular", size: 16)
        self.addSubview(performerNameLabel)
        self.addSubview(performerDescLabel)
        _ = performerNameLabel.anchor(self.topAnchor, left: self.leftAnchor, bottom: nil, right: self.rightAnchor,
                          topConstant: 10, leftConstant: 50, bottomConstant: 0, rightConstant: -20,
                          widthConstant: 0, heightConstant: 22)
        _ = performerDescLabel.anchor(performerNameLabel.bottomAnchor, left: self.leftAnchor, bottom: nil, right:   self.rightAnchor, topConstant: 5, leftConstant: 50, bottomConstant: 0, rightConstant: -20, widthConstant: 0, heightConstant: 16)
        var start = CGPoint(x: 35, y: 0)
        if (isFirst) {
            start = CGPoint(x: 35, y: 22)
        }
        let end = CGPoint(x: 35, y: 80)
        addLine(fromPoint: start, toPoint: end)
        drawRingFittingInsideView()
    }
    
    private func getTimeString(for performer: FlingPerformer) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm"
        dateFormatter.timeZone = TimeZone(abbreviation: "EST")
        let dateFormatterTwelveHour = DateFormatter()
        dateFormatterTwelveHour.timeZone = TimeZone(abbreviation: "EST")
        dateFormatterTwelveHour.dateFormat = "h:mm a"
        return "\(dateFormatter.string(from: performer.startTime)) - \(dateFormatterTwelveHour.string(from: performer.endTime))"
    }
    
    func addLine(fromPoint start: CGPoint, toPoint end:CGPoint, color:UIColor = UIColor.lightGray, width:Int = 2) {
        let line = CAShapeLayer()
        let linePath = UIBezierPath()
        linePath.move(to: start)
        linePath.addLine(to: end)
        line.path = linePath.cgPath
        line.strokeColor = color.cgColor
        line.lineWidth = CGFloat(width)
        line.lineJoin = kCALineJoinRound
        lineLayer = line
        self.layer.addSublayer(line)
    }
    
    func redrawLine() {
        lineLayer.removeFromSuperlayer()
        let top = CGPoint(x: 35, y: 0)
        let start = CGPoint(x: 35, y: 22)
        let end = CGPoint(x: 35, y: 80)
        addLine(fromPoint: top, toPoint: end, color: UIColor.white, width: 5)
        addLine(fromPoint: start, toPoint: end)
        drawRingFittingInsideView()
    }
    
    func drawRingFittingInsideView() {
        let halfSize:CGFloat = CGFloat(5)
        let desiredLineWidth:CGFloat = CGFloat(3)    // your desired value
        
        let circlePath = UIBezierPath(
            arcCenter: CGPoint(x:35,y:22),
            radius: CGFloat( halfSize - (desiredLineWidth/2) ),
            startAngle: CGFloat(0),
            endAngle:CGFloat(CGFloat.pi * 2),
            clockwise: true)
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = circlePath.cgPath
        
        shapeLayer.fillColor = UIColor.lightGray.cgColor
        shapeLayer.strokeColor = UIColor.lightGray.cgColor
        shapeLayer.lineWidth = desiredLineWidth
        
        self.layer.addSublayer(shapeLayer)
    }
}
