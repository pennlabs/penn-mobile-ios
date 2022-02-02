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
    fileprivate var usageData: [Double]!
    fileprivate var graphData = Array(repeating: 0.0, count: 27)

    fileprivate var graphLabel: UILabel!
    fileprivate var dayLabel: UILabel!
    fileprivate var scrollableGraphView: ScrollableGraphView!
    fileprivate var dottedLine: CAShapeLayer!

    fileprivate let dataPointSpacing = 30

    override init(frame: CGRect) {
        super.init(frame: frame)
        prepareUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Animation Logic
extension LaundryGraphView {
    func reload(with newUsageData: [Double]?) {
        reloadDottedLineLayer() // refresh the dotted line that indicates current time
        dayLabel.text = Date.currentDayOfWeek

        if usageData == nil && newUsageData == nil { return }

        if let usageData = usageData, let newUsageData = newUsageData,
            usageData == newUsageData { return }

        if usageData != nil && newUsageData == nil {
            usageData = nil
            graphData = Array(repeating: 0.0, count: graphData.count)
            scrollableGraphView.reload()
            return
        }

        usageData = newUsageData
        scrollGraphToCurrentHour {
            self.animateGraph()
        }
    }

    private func scrollGraphToCurrentHour(_ completion: () -> Void) {
        var currentHour = Calendar.current.component(.hour, from: Date())
        if currentHour > 2 {
            currentHour -= 2
        }
        let newXOffset = currentHour * dataPointSpacing
        let oldXOffset = scrollableGraphView.contentOffset.x
        if oldXOffset == CGFloat(newXOffset) {
            completion()
        } else {
            scrollableGraphView.setContentOffset(CGPoint(x: newXOffset, y: 0), animated: true)
        }
    }

    @objc fileprivate func animateGraph() {
        let when = DispatchTime.now() + 0.2
        DispatchQueue.main.asyncAfter(deadline: when) {
            self.executeGraphAnimation()
        }
    }

    @objc private func executeGraphAnimation() {
        if let usageData = usageData {
            graphData = usageData
            scrollableGraphView.reload()
        }
    }
}

// Mark: - UIScrollViewDelegate
extension LaundryGraphView: UIScrollViewDelegate {
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        animateGraph()
    }
}

// MARK: - ScrollableGraphViewDataSource
extension LaundryGraphView: ScrollableGraphViewDataSource {
    func numberOfPoints() -> Int {
        return graphData.count
    }

    // graphData will initially contain all 0.0s, but will update to real values after API data is recieved
    func value(forPlot plot: Plot, atIndex pointIndex: Int) -> Double {
        if pointIndex < graphData.count {
            return graphData[pointIndex]
        } else {
            return 0.0
        }
    }

    func label(atIndex pointIndex: Int) -> String {
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
}

// MARK: - Prepare UI
extension LaundryGraphView {
    fileprivate func prepareUI() {
        prepareGraphLabel()
        prepareDayLabel()
        prepareScrollableGraphView()
    }

    // MARK: Labels

    private func prepareGraphLabel() {
        let label = UILabel()
        label.text = "Popular Times"
        label.font = UIFont(name: "HelveticaNeue", size: 14)
        label.textColor = .labelPrimary
        label.textAlignment = .left
        graphLabel = label

        addSubview(graphLabel)
        _ = graphLabel.anchor(topAnchor, left: leftAnchor, bottom: nil, right: nil, topConstant: 0, leftConstant: 20, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
    }

    private func prepareDayLabel() {
        let label = UILabel()
        label.text = Date.currentDayOfWeek
        label.font = UIFont(name: "HelveticaNeue", size: 14)
        label.textColor = .labelSecondary
        label.textAlignment = .right
        dayLabel = label

        addSubview(dayLabel)
        _ = dayLabel.anchor(topAnchor, left: nil, bottom: nil, right: rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 20, widthConstant: 0, heightConstant: 0)
    }

    // MARK: Graph View

    // Compose the graph view by creating a graph, then adding any plots
    // and reference lines before adding the graph to the view hierarchy.
    private func prepareScrollableGraphView() {
        let graphView = ScrollableGraphView(frame: .zero, dataSource: self)
        let referenceLines = ReferenceLines()

        let lineColor = UIColor(red: 0.313, green: 0.847, blue: 0.89, alpha: 1.0)
        let fillColorTop = UIColor(red: 0.313, green: 0.847, blue: 0.89, alpha: 0.8)
        let fillColorBottom = UIColor(red: 0.313, green: 0.847, blue: 0.89, alpha: 0.1)
        let dataLabelColor = UIColor.labelSecondary

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
        graphView.rangeMax = 1.0

        graphView.layer.cornerRadius = 15.0

        graphView.addReferenceLines(referenceLines: referenceLines)
        graphView.addPlot(plot: dataLinePlot)
        graphView.showsHorizontalScrollIndicator = false

        // Create/refresh dotted line showing current time
        reloadDottedLineLayer()

        // Need delegate method to pop up graph when scroll to current time is finished
        graphView.delegate = self

        scrollableGraphView = graphView

        addSubview(scrollableGraphView)
        _ = scrollableGraphView.anchor(graphLabel.bottomAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, topConstant: 2, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
    }

    func reloadDottedLineLayer() {
        dottedLine?.removeFromSuperlayer()

        let dottedLineLayer = CAShapeLayer()
        dottedLineLayer.strokeColor = UIColor.grey1.cgColor
        dottedLineLayer.lineWidth = 1.0
        dottedLineLayer.lineCap = CAShapeLayerLineCap.round
        dottedLineLayer.lineDashPattern = [.init(integerLiteral: 5)]

        let currentHour = Calendar.current.component(.hour, from: Date())
        let xPosition = 50.0 + Double(currentHour * dataPointSpacing)

        let linePath = UIBezierPath()
        linePath.move(to: CGPoint(x: xPosition, y: 15.0))
        linePath.addLine(to: CGPoint(x: xPosition, y: 50.0))

        dottedLineLayer.path = linePath.cgPath
        dottedLine = dottedLineLayer
        scrollableGraphView?.layer.addSublayer(dottedLineLayer)
    }
}
