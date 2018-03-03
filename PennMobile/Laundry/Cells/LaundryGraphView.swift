//
//  LaundryGraph.swift
//  PennMobile
//
//  Created by Josh Doman on 3/2/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//

import Foundation
import ScrollableGraphView

final class LaundryGraphView: UIView {
    var usageData: Array<Double>!
    var graphData = Array(repeating: 0.0, count: LaundryCell.numberOfDataPointsInGraph)
    
    fileprivate var graphLabel: UILabel!
    fileprivate var dayLabel: UILabel!
    fileprivate var scrollableGraphView: ScrollableGraphView!
    fileprivate var dottedLine: CAShapeLayer!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        prepareUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Prepare UI
extension LaundryGraphView {
    fileprivate func prepareUI() {
        prepareGraphLabel()
        prepareDayLabel()
    }
    
    // MARK: Labels
    
    private func prepareGraphLabel() {
        let label = UILabel()
        label.text = "Popular Times"
        label.font = UIFont(name: "HelveticaNeue", size: 14)
        label.textColor = .black
        label.textAlignment = .left
        graphLabel = label
        
        addSubview(graphLabel)
        _ = graphLabel.anchor(topAnchor, left: leftAnchor, bottom: nil, right: nil, topConstant: 0, leftConstant: 20, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
    }
    
    private func prepareDayLabel() {
        let label = UILabel()
        label.text = Date.currentDayOfWeek
        label.font = UIFont(name: "HelveticaNeue", size: 14)
        label.textColor = .warmGrey
        label.textAlignment = .right
        dayLabel = label
        
        addSubview(dayLabel)
        _ = dayLabel.anchor(topAnchor, left: nil, bottom: nil, right: rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 20, widthConstant: 0, heightConstant: 0)
    }
    
//    private func prepareScrollableGraphView() {
//        // Compose the graph view by creating a graph, then adding any plots
//        // and reference lines before adding the graph to the view hierarchy.
//        let graphView = ScrollableGraphView(frame: frame, dataSource: self)
//        let referenceLines = ReferenceLines()
//
//        let lineColor = UIColor(red: 0.313, green: 0.847, blue: 0.89, alpha: 1.0)
//        let fillColorTop = UIColor(red: 0.313, green: 0.847, blue: 0.89, alpha: 0.8)
//        let fillColorBottom = UIColor(red: 0.313, green: 0.847, blue: 0.89, alpha: 0.1)
//        let dataLabelColor = UIColor.warmGrey
//
//        // Line plot
//        let dataLinePlot = LinePlot(identifier: "traffic_data")
//        dataLinePlot.lineWidth = 1
//        dataLinePlot.lineColor = lineColor
//        dataLinePlot.lineStyle = ScrollableGraphViewLineStyle.smooth
//
//        dataLinePlot.shouldFill = true
//        dataLinePlot.fillType = ScrollableGraphViewFillType.gradient
//        dataLinePlot.fillGradientType = ScrollableGraphViewGradientType.linear
//        dataLinePlot.fillGradientStartColor = fillColorTop
//        dataLinePlot.fillGradientEndColor = fillColorBottom
//        dataLinePlot.adaptAnimationType = ScrollableGraphViewAnimationType.elastic
//
//        // Reference lines
//        referenceLines.referenceLineColor = .clear
//        referenceLines.referenceLineLabelColor = .clear
//        referenceLines.positionType = .relative
//
//        // Data labels (5am, 2pm, etc.)
//        referenceLines.dataPointLabelColor = dataLabelColor
//        referenceLines.shouldShowLabels = true
//        referenceLines.dataPointLabelsSparsity = 2
//
//        // Setup the graph
//        graphView.backgroundFillColor = UIColor.clear
//        graphView.dataPointSpacing = CGFloat(self.dataPointSpacing)
//
//        graphView.shouldAnimateOnStartup = true
//        graphView.shouldAdaptRange = false
//        graphView.shouldRangeAlwaysStartAtZero = true
//
//        // Enable/disable scrolling
//        graphView.isScrollEnabled = true
//
//        graphView.rangeMin = 0.0
//        graphView.rangeMax = 1.5
//
//        graphView.layer.cornerRadius = 15.0
//
//        graphView.addReferenceLines(referenceLines: referenceLines)
//        graphView.addPlot(plot: dataLinePlot)
//        graphView.showsHorizontalScrollIndicator = false
//
//        // Create/refresh dotted line showing current time
//        reloadDottedLineLayer()
//
//        // Need delegate method to pop up graph when scroll animation is finished
//        graphView.delegate = self
//
//        scrollableGraphView = graphView
//    }
    
}
