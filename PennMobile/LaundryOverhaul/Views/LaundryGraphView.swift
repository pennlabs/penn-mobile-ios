//
//  LaundryGraphView.swift
//  PennMobile
//
//  Created by Dominic Holmes on 8/2/17.
//  Copyright © 2017 Dominic Holmes. All rights reserved.
//

import UIKit

struct CustomGraphRect {
    var x: CGFloat!
    var y: CGFloat!
    var w: CGFloat!
    var h: CGFloat!
}

class LaundryGraphView: UIView {
    
    var primaryDataColor = UIColor(red: 0.0 / 255.0, green: 195.0 / 255.0, blue: 255.0 / 255.0, alpha: 1.0)
    let axisColor = UIColor(white: 0.9, alpha: 1.0)
    let labelColor = UIColor.darkGray
    
    var viewHeight: CGFloat!
    var viewWidth: CGFloat!
    var graphHeight: CGFloat!
    var graphWidth: CGFloat!
    var graphFrame: CGRect!
    
    var dataMax: CGFloat!
    var dataMin: CGFloat!
    var dataRange: CGFloat!
    
    var dataToGraph: [Int] = [1, 2, 3, 2, 4,
                              3, 1, 1, 2, 3]
    var xAxisLabels: [String] = ["8a", "9a", "10a", "11a", "12p",
                                 "1p", "2p", "3p", "4p", "5p",
                                 "", "", "", "", "",
                                 "", "", "", "", "",
                                 "", "", "", "", "",
                                 ""]
    
    var finalDataRects: [CustomGraphRect] = [CustomGraphRect]()
    var startingDataRects: [CustomGraphRect] = [CustomGraphRect]()
    
    var dataRectangles: [CAShapeLayer] = [CAShapeLayer]()
    var dataRectanglesFinalPaths: [UIBezierPath] = [UIBezierPath]()
    
    var axisLines: [CAShapeLayer] = [CAShapeLayer]()
    var axisLabels: [UILabel] = [UILabel]()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func initializeGraph() {
        initializeGraphFrame()
        drawGraphAxis()
        initializeDataGraphics()
    }
    
    func initializeGraphFrame() {
        // CHANGE THESE VALUES TO FILL THE VIEW
        self.viewHeight = 180.0
        self.viewWidth = 300.0
        self.graphHeight = (0.8 * viewHeight)
        self.graphWidth = (0.95 * viewWidth)
        self.graphFrame = CGRect(x: 0.0 + ((viewWidth - graphWidth) / 2.0) + 10.0,
                                 y: 0.0 + ((viewHeight - graphHeight) / 2.0) + (graphHeight * 0.1),
                                 width: graphWidth, height: graphHeight)
        
        self.dataMax = CGFloat(self.dataToGraph.max()!)
        self.dataMin = CGFloat(self.dataToGraph.min()!)
        
        self.dataRange = self.dataMax - self.dataMin
        if dataRange == 0 {
            self.dataMin = 0
            self.dataMax = 20
            self.dataRange = 20
        }
    }
    
    // Populate the graph with circles representing datapoints
    
    func initializeDataGraphics() {
        findDataCoordinates()
        drawDataRectangles()
    }
    
    func findDataCoordinates() {
        var tempDataCoordinates = [CustomGraphRect]()
        var tempStartingDataCoordinates = [CustomGraphRect]()
        
        let xInterval = (graphWidth) / CGFloat(dataToGraph.count)
        
        for eachPoint in dataToGraph.indices {
            let valueOfPoint = dataToGraph[eachPoint]
            let xCoordinate = graphFrame.origin.x + (xInterval * CGFloat(eachPoint))
            let yCoordinate = graphFrame.origin.y + graphFrame.height
            let rectWidth = xInterval
            if dataMax == 0.0 {
                dataMax = 1.0
            }
            let rectHeight = graphHeight - ((dataMax - CGFloat(valueOfPoint)) / dataMax) * graphHeight
            tempDataCoordinates.append(CustomGraphRect(x: xCoordinate, y: yCoordinate, w: rectWidth, h: rectHeight))
            tempStartingDataCoordinates.append(CustomGraphRect(x: xCoordinate, y: yCoordinate, w: rectWidth, h: 0.0))
        }
        finalDataRects = tempDataCoordinates
        startingDataRects = tempStartingDataCoordinates
        
    }
    
    func drawDataRectangles() {
        dataRectangles = [CAShapeLayer]()
        for eachIndex in dataToGraph.indices {
            dataRectangles.append(
                addRectangle(with: startingDataRects[eachIndex],
                             ofColor: primaryDataColor.cgColor))
            let finalRectPath = getRectanglePath(with: finalDataRects[eachIndex])
            dataRectanglesFinalPaths.append(finalRectPath)
        }
    }
    
    // Create the axis of the graph
    
    func drawGraphAxis() {
        var tempAxisLines: [CAShapeLayer] = [CAShapeLayer]()
        tempAxisLines.append(addLine(fromPoint: CGPoint(x: graphFrame.origin.x, y: graphFrame.origin.y),
                                     toPoint: CGPoint(x: graphFrame.origin.x + graphWidth, y: graphFrame.origin.y),
                                     ofColor: axisColor.cgColor)!)
        
        tempAxisLines.append(addLine(fromPoint: CGPoint(x: graphFrame.origin.x, y: graphFrame.origin.y + 0.5 * graphHeight),
                                     toPoint: CGPoint(x: graphFrame.origin.x + graphWidth, y: graphFrame.origin.y + 0.5 * graphHeight),
                                     ofColor: axisColor.cgColor)!)
        
        tempAxisLines.append(addLine(fromPoint: CGPoint(x: graphFrame.origin.x, y: graphFrame.origin.y + graphHeight),
                                     toPoint: CGPoint(x: graphFrame.origin.x + graphWidth, y: graphFrame.origin.y + graphHeight),
                                     ofColor: axisColor.cgColor)!)
        self.axisLines = tempAxisLines
        self.axisLabels = [UILabel]()
        generateAxisXLabels()
        generateAxisYLabels()
    }
    
    // Functions that create basic objects
    
    func addLine(fromPoint start: CGPoint, toPoint end: CGPoint, ofColor color: CGColor) -> CAShapeLayer? {
        let line = CAShapeLayer()
        let linePath = UIBezierPath()
        linePath.move(to: start)
        linePath.addLine(to: end)
        line.path = linePath.cgPath
        line.strokeColor = color
        line.lineWidth = 1
        line.lineJoin = kCALineJoinRound
        self.layer.addSublayer(line)
        return line
    }
    
    func addRectangle(with customRect: CustomGraphRect, ofColor color: CGColor) -> CAShapeLayer {
        let shapeLayer = CAShapeLayer()
        let rect: CGRect = CGRect(x: customRect.x + 1, y: customRect.y - customRect.h,
                                  width: customRect.w - 2, height: customRect.h)
        shapeLayer.path = UIBezierPath(roundedRect: rect, cornerRadius: 2.0).cgPath
        shapeLayer.fillColor = color
        layer.addSublayer(shapeLayer)
        return shapeLayer
    }
    
    func getRectanglePath(with customRect: CustomGraphRect) -> UIBezierPath {
        let rect: CGRect = CGRect(x: customRect.x + 1, y: customRect.y - customRect.h,
                                  width: customRect.w - 2, height: customRect.h)
        return UIBezierPath(roundedRect: rect, cornerRadius: 2.0)
    }
    
    func createLabel(fromString text: String!, insideRect rect: CGRect, onAxis axis: String) -> UILabel {
        let labelString = NSMutableAttributedString(
            string: text,
            attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 12.0, weight: UIFontWeightUltraLight)])
        let newLabel = UILabel(frame: rect)
        newLabel.attributedText = labelString
        newLabel.textColor = labelColor
        if axis == "y" { newLabel.textAlignment = .right } else { newLabel.textAlignment = .left }
        self.addSubview(newLabel)
        return newLabel
    }
    
    // Create labels for the axes
    
    func generateAxisYLabels() {
        axisLabels.append(createLabel(fromString: "\(Int(dataMax))",
            insideRect: CGRect(x: graphFrame.origin.x - 67,
                               y: graphFrame.origin.y - (21.0 / 2.0),
                               width: 62.0, height: 21.0),
            onAxis: "y"))
        axisLabels.append(createLabel(fromString: "\(Int((dataRange / 2.0) + dataMin))",
            insideRect: CGRect(x: graphFrame.origin.x - 67,
                               y: graphFrame.origin.y + (graphHeight / 2.0) - (21.0 / 2.0),
                               width: 62.0, height: 21.0),
            onAxis: "y"))
        axisLabels.append(createLabel(fromString: "\(Int(dataMin))",
            insideRect: CGRect(x: graphFrame.origin.x - 67,
                               y: graphFrame.origin.y + graphHeight - (21.0 / 2.0),
                               width: 62.0, height: 21.0),
            onAxis: "y"))
    }
    
    func generateAxisXLabels() {
        let xInterval = (graphWidth) / CGFloat(dataToGraph.count + 1)
        for eachPoint in dataToGraph.indices {
            let xCoordinate = graphFrame.origin.x + (xInterval * CGFloat(eachPoint + 1) - 4.0)
            let yCoordinate = graphFrame.origin.y + (graphHeight * 0.95)
            axisLabels.append(createLabel(fromString: xAxisLabels[eachPoint],
                                          insideRect: CGRect(x: xCoordinate, y: yCoordinate, width: 48.0, height: 21.0),
                                          onAxis: "x"))
        }
    }
    
    // Animation functions
    
    func animateDataRectangles(withDuration duration: TimeInterval) {
        for eachRectIndex in dataRectangles.indices {
            let rectangle = dataRectangles[eachRectIndex]
            let startPath = rectangle.path
            let endPath = dataRectanglesFinalPaths[eachRectIndex]
            let animation = CABasicAnimation(keyPath: "path")
            animation.fromValue = startPath
            animation.toValue = endPath
            animation.duration = duration
            animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
            rectangle.add(animation, forKey: "path")
            rectangle.path = endPath.cgPath
        }
    }
    
    // Deletion function
    
    func clearGraph() {
        for eachLine in axisLines {
            eachLine.removeFromSuperlayer()
        }
        for eachLabel in axisLabels {
            eachLabel.removeFromSuperview()
        }
        for eachCircle in dataRectangles {
            eachCircle.removeFromSuperlayer()
        }
        finalDataRects = [CustomGraphRect]()
        startingDataRects = [CustomGraphRect]()
        dataRectangles = [CAShapeLayer]()
        dataRectanglesFinalPaths = [UIBezierPath]()
        axisLines = [CAShapeLayer]()
        axisLabels = [UILabel]()
    }
}
