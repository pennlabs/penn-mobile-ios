//
//  LaundryCell + Graph.swift
//  PennMobile
//
//  Created by Josh Doman on 1/16/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//

import Foundation
import ScrollableGraphView

// MARK: - Scrollable Graph View

extension LaundryCell: ScrollableGraphViewDataSource {    
    internal func generateScrollableGraphView(_ frame: CGRect) -> ScrollableGraphView {
        // Compose the graph view by creating a graph, then adding any plots
        // and reference lines before adding the graph to the view hierarchy.
        let graphView = ScrollableGraphView(frame: frame, dataSource: self)
        let referenceLines = ReferenceLines()
        
        let lineColor = UIColor(red: 0.313, green: 0.847, blue: 0.89, alpha: 1.0)
        let fillColorTop = UIColor(red: 0.313, green: 0.847, blue: 0.89, alpha: 0.8)
        let fillColorBottom = UIColor(red: 0.313, green: 0.847, blue: 0.89, alpha: 0.1)
        let dataLabelColor = UIColor.warmGrey
        
        // Line plot
        let dataLinePlot = LinePlot(identifier: "traffic_data")
        dataLinePlot.lineWidth = 1
        dataLinePlot.lineColor = lineColor
        dataLinePlot.lineStyle = ScrollableGraphViewLineStyle.smooth
        
        dataLinePlot.shouldFill = true
        dataLinePlot.fillType = ScrollableGraphViewFillType.gradient
        dataLinePlot.fillGradientType = ScrollableGraphViewGradientType.linear
        dataLinePlot.fillGradientStartColor = fillColorTop
        dataLinePlot.fillGradientEndColor = fillColorBottom
        dataLinePlot.adaptAnimationType = ScrollableGraphViewAnimationType.elastic
        
        // Reference lines
        referenceLines.referenceLineColor = .clear
        referenceLines.referenceLineLabelColor = .clear
        referenceLines.positionType = .relative
        
        // Data labels (5am, 2pm, etc.)
        referenceLines.dataPointLabelColor = dataLabelColor
        referenceLines.shouldShowLabels = true
        referenceLines.dataPointLabelsSparsity = 2
        
        // Setup the graph
        graphView.backgroundFillColor = UIColor.clear
        graphView.dataPointSpacing = CGFloat(self.dataPointSpacing)
        
        graphView.shouldAnimateOnStartup = true
        graphView.shouldAdaptRange = false
        graphView.shouldRangeAlwaysStartAtZero = true
        
        // Enable/disable scrolling
        graphView.isScrollEnabled = true
        
        graphView.rangeMin = 0.0
        graphView.rangeMax = 1.5
        
        graphView.layer.cornerRadius = 20
        
        graphView.addReferenceLines(referenceLines: referenceLines)
        graphView.addPlot(plot: dataLinePlot)
        graphView.showsHorizontalScrollIndicator = false
        
        // Create/refresh dotted line showing current time
        reloadDottedLineLayer()
        
        // Need delegate method to pop up graph when scroll animation is finished
        graphView.delegate = self
        
        return graphView
    }
    
    func reloadDottedLineLayer() {
        dottedLineShapeLayer?.removeFromSuperlayer()
        
        let dottedLineLayer = CAShapeLayer()
        dottedLineLayer.strokeColor = UIColor.warmGrey.cgColor
        dottedLineLayer.lineWidth = 1.0
        dottedLineLayer.lineCap = kCALineCapRound
        dottedLineLayer.lineDashPattern = [.init(integerLiteral: 5)]
        
        let currentHour = Calendar.current.component(.hour, from: Date())
        let xPosition = 50.0 + Double(currentHour * dataPointSpacing)
        
        let linePath = UIBezierPath()
        linePath.move(to: CGPoint(x: xPosition, y: 25.0))
        linePath.addLine(to: CGPoint(x: xPosition, y: 60.0))
        
        dottedLineLayer.path = linePath.cgPath
        dottedLineShapeLayer = dottedLineLayer
        scrollableGraphView?.layer.addSublayer(dottedLineLayer)
    }
    
    internal func value(forPlot plot: Plot, atIndex pointIndex: Int) -> Double {
        // graphData will initially contain all 0.0s, but will update to real values after API data is recieved
        if pointIndex < graphData.count {
            return graphData[pointIndex]
        } else {
            return 0.0
        }
    }
    
    internal func label(atIndex pointIndex: Int) -> String {
        if pointIndex == 0 {
            return "12a"
        } else if pointIndex < 12 {
            return "\(pointIndex)a"
        } else if pointIndex == 12 {
            return "12p"
        } else if pointIndex < 24 {
            return "\(pointIndex - 12)p"
        } else if pointIndex == 24 {
            return "12a"
        } else if pointIndex > 24 {
            return "\(pointIndex - 24)a"
        } else {
            return ""
        }
    }
    
    internal func numberOfPoints() -> Int {
        return numberOfDataPointsInGraph
    }
    
    func reloadGraphDataIfNeeded(oldRoom: LaundryRoom?, newRoom: LaundryRoom?) {
        reloadDottedLineLayer() // refresh the dotted line that indicates current time
        
        if usageData == nil && newRoom?.usageData == nil { return }
        
        if let usageData = usageData, let newUsageData = newRoom?.usageData,
            usageData == newUsageData { return }
        
        if usageData != nil && newRoom?.usageData == nil {
            usageData = nil
            graphData = Array(repeating: 0.0, count: self.numberOfDataPointsInGraph)
            scrollableGraphView?.reload()
            return
        }
        
        usageData = newRoom?.usageData
        scrollGraphToCurrentHour {
            self.animateGraph()
        }
    }
    
    fileprivate func scrollGraphToCurrentHour(_ completion: () -> Void) {
        // Graph is scrolled as soon as the room is passed to the laundry cell
        var currentHour = Calendar.current.component(.hour, from: Date())
        if currentHour > 2 {
            currentHour -= 2
        }
        let newXOffset = currentHour * dataPointSpacing
        if let oldXOffset = scrollableGraphView?.contentOffset.x, oldXOffset == CGFloat(newXOffset) {
            completion()
        } else {
            scrollableGraphView?.setContentOffset(CGPoint(x: newXOffset, y: 0), animated: true)
        }
    }
    
    @objc fileprivate func animateGraph() {
        let when = DispatchTime.now() + 0.2
        DispatchQueue.main.asyncAfter(deadline: when) {
            self.executeGraphAnimation()
        }
    }
    
    @objc fileprivate func executeGraphAnimation() {
        if let usageData = usageData?.data {
            for i in self.graphData.indices {
                if i < usageData.count {
                    graphData[i] = usageData[i]
                }
            }
            scrollableGraphView?.reload()
        }
    }
    
    internal func scrollAndUpdateGraph() {
        scrollGraphToCurrentHour {
            self.animateGraph()
        }
    }
}

// Mark: - UIScrollViewDelegate

extension LaundryCell: UIScrollViewDelegate {
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        animateGraph()
    }
}
