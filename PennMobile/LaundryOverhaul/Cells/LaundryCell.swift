//
//  LaundryCell.swift
//  PennMobile
//
//  Created by Dominic Holmes on 9/30/17.
//  Copyright © 2017 PennLabs. All rights reserved.
//

import UIKit
import ScrollableGraphView

// MARK: - Laundry Cell Delegate Protocol

protocol LaundryCellDelegate: class {
    func deleteLaundryCell(for hall: LaundryHall)
    //func toggleGraphView(_ cell: LaundryCell)
}

// MARK: - Laundry Cell

class LaundryCell: UITableViewCell {
    
    weak var delegate: LaundryCellDelegate?
    
    var room: LaundryHall! {
        didSet {
            roomLabel.text = room.building
            roomFloorLabel.text = room.name
            washerCollectionView?.reloadData()
            dryerCollectionView?.reloadData()
        }
    }
    
    var isDryerGraph = false
    
    
    // BEGIN TEST - DUMMY DATA
    // For testing the new scrollable graph
    fileprivate var numberOfDataPointsInGraph = 26
    fileprivate var linePlotData = [2.0, 2.2, 2.4, 0.0, 1.1, 2.0, 2.2, 1.4, 2.0, 3.0,
                                    2.0, 1.2, 2.4, 1.0, 2.1, 3.0, 2.2, 2.4, 2.0, 1.1,
                                    2.0, 0.0, 2.0, 1.0, 3.0, 2.4]
    fileprivate var emptyLinePlotData = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
                                         0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
                                         0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
    // END TEST
    
    // MARK: - Define UI Element Variables
    
    fileprivate var washerCollectionView: UICollectionView?
    fileprivate var dryerCollectionView: UICollectionView?
    fileprivate var scrollableGraphView: ScrollableGraphView?
    
    fileprivate let bgView: UIView = {
        let bg = UIView()
        /*
         let gradient: CAGradientLayer = CAGradientLayer()
         
         gradient.colors = [UIColor.init(red: 250.0 / 255.0, green: 250.0 / 255.0, blue: 250.0 / 255.0, alpha: 1.0).cgColor,
         UIColor.init(red: 245.0 / 255.0, green: 245.0 / 255.0, blue: 245.0 / 255.0, alpha: 1.0).cgColor]
         gradient.locations = [0.0 , 1.0]
         gradient.startPoint = CGPoint(x: 0.0, y: 0.0)
         gradient.endPoint = CGPoint(x: 0.0, y: 1.0)
         gradient.frame = CGRect(x: 0.0, y: 0.0, width: 500.0, height: 350.0)
         
         bg.layer.insertSublayer(gradient, at: 0)
         
         bg.clipsToBounds = true
         bg.layer.cornerRadius = 15
         bg.layer.masksToBounds = true*/
        
        // corner radius
        bg.layer.cornerRadius = 20
        
        // border
        bg.layer.borderWidth = 0.0
        bg.layer.borderColor = UIColor.black.cgColor
        
        // shadow
        bg.layer.shadowColor = UIColor.black.cgColor
        bg.layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
        bg.layer.shadowOpacity = 0.8
        bg.layer.shadowRadius = 3.0
        bg.backgroundColor = UIColor.whiteGrey
        
        return bg
    }()
    
    fileprivate lazy var xButton: UIButton = {
        let xb = UIButton()
        xb.backgroundColor = UIColor.clear
        xb.contentMode = .scaleAspectFill
        xb.clipsToBounds = true
        xb.layer.cornerRadius = 20
        xb.layer.masksToBounds = true
        xb.setBackgroundImage(UIImage(named: "x_button"), for: UIControlState.normal)
        xb.setBackgroundImage(UIImage(named: "x_button_selected"), for: .selected)
        xb.setBackgroundImage(UIImage(named: "x_button_selected"), for: .highlighted)
        xb.addTarget(self, action: #selector(deleteRoom), for: .touchUpInside)
        return xb
    }()
    
    fileprivate lazy var graphButton: UIButton = {
        let b = UIButton()
        b.titleLabel?.text = "Average Busy Washers"
        b.setTitle("Average Busy Washers", for: .normal)
        b.setTitleColor(UIColor.buttonBlue, for: .normal)
        b.titleLabel?.font = UIFont(name: "HelveticaNeue", size: 14)
        b.backgroundColor = UIColor.clear
        b.addTarget(self, action: #selector(toggleGraph), for: .touchUpInside)
        return b
    }()
    
    fileprivate let washersDryersView: UIView = {
        let v = UIView()
        v.backgroundColor = .clear
        return v
    }()
    
    fileprivate let washerView: UIView = {
        let v = UIView()
        v.backgroundColor = .clear
        return v
    }()
    
    fileprivate let washerCollectionViewContainer: UIView = {
        let v = UIView()
        v.backgroundColor = .clear
        return v
    }()
    
    fileprivate let dryerView: UIView = {
        let v = UIView()
        v.backgroundColor = .clear
        return v
    }()
    
    fileprivate let dryerCollectionViewContainer: UIView = {
        let v = UIView()
        v.backgroundColor = .clear
        return v
    }()
    
    fileprivate let roomLabel: UILabel = {
        let label = UILabel()
        label.text = "Laundry Room"
        label.font = UIFont(name: "HelveticaNeue", size: 14)
        label.textColor = .warmGrey
        label.textAlignment = .left
        return label
    }()
    
    fileprivate let roomFloorLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.font = UIFont(name: "HelveticaNeue", size: 24)
        label.textColor = .black
        label.textAlignment = .left
        return label
    }()
    
    fileprivate let washersLabel: UILabel = {
        let label = UILabel()
        label.text = "Washers"
        label.font = UIFont(name: "HelveticaNeue", size: 14)
        label.textColor = .black
        label.layer.cornerRadius = 4
        label.layer.masksToBounds = true
        label.textAlignment = .left
        return label
    }()
    
    fileprivate let dryersLabel: UILabel = {
        let label = UILabel()
        label.text = "Dryers"
        label.font = UIFont(name: "HelveticaNeue", size: 14)
        label.textColor = .black
        label.layer.cornerRadius = 4
        label.layer.masksToBounds = true
        label.textAlignment = .left
        return label
    }()
    
    fileprivate let numWashersLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.font = UIFont(name: "HelveticaNeue", size: 16)
        label.textColor = .warmGrey
        label.layer.cornerRadius = 4
        label.layer.masksToBounds = true
        label.textAlignment = .right
        return label
    }()
    
    fileprivate let numDryersLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.font = UIFont(name: "HelveticaNeue", size: 16)
        
        label.textColor = .warmGrey
        label.layer.cornerRadius = 4
        label.layer.masksToBounds = true
        label.textAlignment = .right
        return label
    }()
    
    fileprivate let graphViewContainer: UIView = {
        let v = UIView()
        v.backgroundColor = .clear
        return v
    }()
    
    fileprivate let borderView: UIView = {
        let bv = UIView()
        bv.backgroundColor = .lightGray
        return bv
    }()
    
    // MARK: - Init
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Layout Views, Constraints
    
    func setupViews() {
        
        for eachView in self.subviews {
            eachView.removeFromSuperview()
        }
        
        addSubview(bgView)
        
        // BackgroundImageView
        _ = bgView.anchor(topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor,
                          topConstant: 15, leftConstant: 20, bottomConstant: 10, rightConstant: 20,
                          widthConstant: 0, heightConstant: 0)
        
        bgView.addSubview(roomLabel)
        bgView.addSubview(roomFloorLabel)
        bgView.addSubview(washersDryersView)
        bgView.addSubview(borderView)
        bgView.addSubview(washerView)
        
        bgView.addSubview(washerCollectionViewContainer)
        washerCollectionView = generateCollectionView(washerCollectionViewContainer.frame)
        bgView.addSubview(washerCollectionView!)
        
        bgView.addSubview(dryerView)
        bgView.addSubview(dryerCollectionViewContainer)
        dryerCollectionView = generateCollectionView(dryerCollectionViewContainer.frame)
        bgView.addSubview(dryerCollectionView!)
        
        bgView.addSubview(graphViewContainer)
        scrollableGraphView = generateScrollableGraphView(graphViewContainer.frame)
        bgView.addSubview(scrollableGraphView!)
        bgView.addSubview(graphButton)
        
        
        bgView.addSubview(washersLabel)
        bgView.addSubview(dryersLabel)
        
        bgView.addSubview(numWashersLabel)
        bgView.addSubview(numDryersLabel)
        
        // X Button
        bgView.addSubview(xButton)
        xButton.translatesAutoresizingMaskIntoConstraints = false
        
        xButton.heightAnchor.constraint(equalToConstant: 25).isActive = true
        xButton.widthAnchor.constraint(
            equalTo: xButton.heightAnchor).isActive = true
        xButton.trailingAnchor.constraint(
            equalTo: bgView.trailingAnchor,
            constant: -15).isActive = true
        xButton.centerYAnchor.constraint(
            equalTo: roomFloorLabel.centerYAnchor).isActive = true
        
        // WashersDryersView
        _ = washersDryersView.anchor(bgView.topAnchor, left: bgView.leftAnchor,
                                     bottom: nil, right: bgView.rightAnchor,
                                     topConstant: 70, leftConstant: 0, bottomConstant: 10, rightConstant: 0,
                                     widthConstant: 0, heightConstant: 200.0)
        
        _ = borderView.anchor(nil, left: washersDryersView.leftAnchor,
                              bottom: washersDryersView.topAnchor, right: washersDryersView.rightAnchor,
                              topConstant: 0, leftConstant: 10, bottomConstant: 0, rightConstant: 10,
                              widthConstant: 0, heightConstant: 1)
        
        // Washer View
        _ = washerView.anchor(washersDryersView.topAnchor, left: washersDryersView.leftAnchor,
                              bottom: nil, right: washersDryersView.rightAnchor,
                              topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0,
                              widthConstant: 0, heightConstant: 0)
        washerView.heightAnchor.constraint(
            equalTo: washersDryersView.heightAnchor,
            multiplier: 0.5).isActive = true
        
        // Washer Collection View
        _ = washerCollectionView!.anchor(washerView.topAnchor, left: washerView.leftAnchor,
                                         bottom: washerView.bottomAnchor, right: washerView.rightAnchor,
                                         topConstant: 20, leftConstant: 0, bottomConstant: 0, rightConstant: 0,
                                         widthConstant: 0, heightConstant: 0)
        
        // Dryer View
        _ = dryerView.anchor(nil, left: washersDryersView.leftAnchor,
                             bottom: washersDryersView.bottomAnchor, right: washersDryersView.rightAnchor,
                             topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0,
                             widthConstant: 0, heightConstant: 0)
        dryerView.heightAnchor.constraint(
            equalTo: washersDryersView.heightAnchor,
            multiplier: 0.5).isActive = true
        
        // Dryer Collection View
        _ = dryerCollectionView!.anchor(dryerView.topAnchor, left: dryerView.leftAnchor,
                                        bottom: dryerView.bottomAnchor, right: dryerView.rightAnchor,
                                        topConstant: 10, leftConstant: 0, bottomConstant: 0, rightConstant: 0,
                                        widthConstant: 0, heightConstant: 0)
        
        // Scrollable Graph View
        _ = graphViewContainer.anchor(washersDryersView.bottomAnchor, left: bgView.leftAnchor,
                                        bottom: bgView.bottomAnchor, right: bgView.rightAnchor,
                                        topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0,
                                        widthConstant: 0, heightConstant: 0)
        _ = scrollableGraphView!.anchor(graphViewContainer.topAnchor, left: graphViewContainer.leftAnchor,
                                        bottom: graphViewContainer.bottomAnchor, right: graphViewContainer.rightAnchor,
                                        topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0,
                                        widthConstant: 0, heightConstant: 0)
        
        // Building Floor Label
        roomFloorLabel.translatesAutoresizingMaskIntoConstraints = false
        roomFloorLabel.leadingAnchor.constraint(
            equalTo: bgView.leadingAnchor,
            constant: 20).isActive = true
        roomFloorLabel.topAnchor.constraint(
            equalTo: bgView.topAnchor,
            constant: 10).isActive = true
        
        // Room Label (Building name)
        roomLabel.translatesAutoresizingMaskIntoConstraints = false
        roomLabel.leadingAnchor.constraint(
            equalTo: bgView.leadingAnchor,
            constant: 20).isActive = true
        roomLabel.topAnchor.constraint(
            equalTo: roomFloorLabel.bottomAnchor,
            constant: 3).isActive = true
        
        // "Washers" Label
        washersLabel.translatesAutoresizingMaskIntoConstraints = false
        washersLabel.leadingAnchor.constraint(
            equalTo: washerView.leadingAnchor,
            constant: 20).isActive = true
        washersLabel.topAnchor.constraint(
            equalTo: washerView.topAnchor,
            constant: 8).isActive = true
        
        // "Num Washers" Label
        numWashersLabel.translatesAutoresizingMaskIntoConstraints = false
        numWashersLabel.trailingAnchor.constraint(
            equalTo: washerView.trailingAnchor,
            constant: -10).isActive = true
        numWashersLabel.centerYAnchor.constraint(
            equalTo: washersLabel.centerYAnchor,
            constant: 0).isActive = true
        
        // "Dryers" Label
        dryersLabel.translatesAutoresizingMaskIntoConstraints = false
        dryersLabel.leadingAnchor.constraint(
            equalTo: dryerView.leadingAnchor,
            constant: 20).isActive = true
        dryersLabel.topAnchor.constraint(
            equalTo: dryerView.topAnchor,
            constant: 2).isActive = true
        
        // "Num Dryers" Label
        numDryersLabel.translatesAutoresizingMaskIntoConstraints = false
        numDryersLabel.trailingAnchor.constraint(
            equalTo: dryerView.trailingAnchor,
            constant: -10).isActive = true
        numDryersLabel.centerYAnchor.constraint(
            equalTo: dryersLabel.centerYAnchor,
            constant: 0).isActive = true
        
        // Graph Button
        graphButton.translatesAutoresizingMaskIntoConstraints = false
        graphButton.leadingAnchor.constraint(
            equalTo: washersLabel.leadingAnchor).isActive = true
        graphButton.topAnchor.constraint(
            equalTo: graphViewContainer.topAnchor,
            constant: -14).isActive = true
    }
    
}

// MARK: - Scrollable Graph View

extension LaundryCell: ScrollableGraphViewDataSource {
    fileprivate func generateScrollableGraphView(_ frame: CGRect) -> ScrollableGraphView {
        // Compose the graph view by creating a graph, then adding any plots
        // and reference lines before adding the graph to the view hierarchy.
        let graphView = ScrollableGraphView(frame: frame, dataSource: self)
        let referenceLines = ReferenceLines()
        
        /*let zerosLinePlot = LinePlot(identifier: "zero_data")
        zerosLinePlot.lineWidth = 1
        zerosLinePlot.lineColor = UIColor.clear
        zerosLinePlot.lineStyle = ScrollableGraphViewLineStyle.smooth
        
        zerosLinePlot.shouldFill = true
        zerosLinePlot.fillType = ScrollableGraphViewFillType.gradient
        zerosLinePlot.fillGradientType = ScrollableGraphViewGradientType.linear
        let color = UIColor(red: 0.313, green: 0.847, blue: 0.89, alpha: 1.0)
        zerosLinePlot.fillGradientStartColor = color
        zerosLinePlot.fillGradientEndColor = color
        zerosLinePlot.adaptAnimationType = ScrollableGraphViewAnimationType.elastic*/
        
        let dataLinePlot = LinePlot(identifier: "traffic_data")
        dataLinePlot.lineWidth = 1
        dataLinePlot.lineColor = UIColor.black
        dataLinePlot.lineStyle = ScrollableGraphViewLineStyle.smooth
        
        dataLinePlot.shouldFill = true
        dataLinePlot.fillType = ScrollableGraphViewFillType.gradient
        dataLinePlot.fillGradientType = ScrollableGraphViewGradientType.linear
        let color = UIColor(red: 0.313, green: 0.847, blue: 0.89, alpha: 1.0)
        dataLinePlot.fillGradientStartColor = color
        dataLinePlot.fillGradientEndColor = color
        dataLinePlot.adaptAnimationType = ScrollableGraphViewAnimationType.elastic

        
        /*
        referenceLines.referenceLineLabelFont = UIFont.boldSystemFont(ofSize: 8)
        referenceLines.referenceLineColor = UIColor.black
        referenceLines.referenceLineLabelColor = UIColor.black
        
        
        referenceLines.positionType = .relative
        // Reference lines will be shown at these values on the y-axis.
        referenceLines.includeMinMax = true*/
        
        
        // Customize the data labels (5am, 2pm, etc.)
        referenceLines.dataPointLabelColor = .black
        referenceLines.shouldShowLabels = true
        referenceLines.dataPointLabelsSparsity = 4
        
        
        
        // Setup the graph
        graphView.backgroundFillColor = UIColor.clear
        graphView.dataPointSpacing = 20
        
        graphView.shouldAnimateOnStartup = true
        graphView.shouldAdaptRange = false
        graphView.shouldRangeAlwaysStartAtZero = true
        
        graphView.rangeMin = 0.0
        graphView.rangeMax = 1.5
        
        graphView.layer.cornerRadius = 20
        
        graphView.addReferenceLines(referenceLines: referenceLines)
        //graphView.addPlot(plot: zerosLinePlot)
        graphView.addPlot(plot: dataLinePlot)
        graphView.showsHorizontalScrollIndicator = false
        
        return graphView
    }
    
    internal func value(forPlot plot: Plot, atIndex pointIndex: Int) -> Double {
        
        let pulledDataPoints = room.getUsageData()
        
        if let _ = pulledDataPoints {
            return pulledDataPoints![pointIndex]
        } else {
            return 0.0
        }
        
        
        
        /*
        
        // Return the data for each plot.
        switch(plot.identifier) {
        case "washer":
            if (!isDryerGraph) {
                return linePlotData[pointIndex]
            } else {
                return emptyLinePlotData[pointIndex]
            }
        case "dryer":
            if (isDryerGraph) {
                return linePlotData[pointIndex]
            } else {
                return emptyLinePlotData[pointIndex]
            }
        default:
            return 0
        }*/
    }
    
    internal func label(atIndex pointIndex: Int) -> String {
        return "H \(pointIndex)"
    }
    
    internal func numberOfPoints() -> Int {
        return numberOfDataPointsInGraph
    }
}

// MARK: - Machine CollectionView Delegate, Datasource

extension LaundryCell: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate {
    fileprivate func generateCollectionView(_ frame: CGRect) -> UICollectionView {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: frame, collectionViewLayout: flowLayout)
        collectionView.register(LaundryMachineCell.self, forCellWithReuseIdentifier: "collectionCell")
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = UIColor.clear
        collectionView.showsHorizontalScrollIndicator = false
        
        return collectionView
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == washerCollectionView {
            let numItems = room.numWasherOpen + room.numWasherRunning + room.numWasherOffline + room.numWasherOutOfOrder
            if numItems == 0 {
                numWashersLabel.text = ""
                //washerLoadingSpinner.startAnimating()
            } else {
                numWashersLabel.text = "\(room.numWasherOpen) of \(numItems) open"
                //washerLoadingSpinner.stopAnimating()
            }
            return numItems
        } else if collectionView == dryerCollectionView {
            let numItems = room.numDryerOpen + room.numDryerRunning + room.numDryerOffline + room.numDryerOutOfOrder
            if numItems == 0 {
                numDryersLabel.text = ""
                //dryerLoadingSpinner.startAnimating()
            } else {
                numDryersLabel.text = "\(room.numDryerOpen) of \(numItems) open"
                //dryerLoadingSpinner.stopAnimating()
            }
            return numItems
        } else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionCell", for: indexPath as IndexPath) as! LaundryMachineCell
        cell.backgroundColor = UIColor.clear
        let cellMachineTypeWasher: Bool = {
            if collectionView == washerCollectionView {
                return true
            } else {
                return false
            }
        }()
        /* ////// This code presents open machines first
         if let room = room {
         if cellMachineTypeWasher {
         if (indexPath.row < room.numWasherOpen) {
         cell.bgImageColor = UIColor.clear
         cell.bgImage = UIImage(named: "washer_open")
         cell.timerText = ""
         } else if (indexPath.row < room.numWasherOpen + room.numWasherRunning) {
         cell.bgImageColor = UIColor.clear
         cell.bgImage = UIImage(named: "washer_busy")
         if (indexPath.row - room.numWasherOpen) < room.remainingTimeWashers.count {
         let time = room.remainingTimeWashers[indexPath.row - room.numWasherOpen]
         cell.timerText = "\(time)"
         }
         } else {
         cell.bgImageColor = UIColor.clear
         cell.bgImage = UIImage(named: "washer_broken")
         cell.timerText = ""
         }
         } else {
         if (indexPath.row < room.numDryerOpen) {
         cell.bgImageColor = UIColor.clear
         cell.bgImage = UIImage(named: "dryer_open")
         cell.timerText = ""
         } else if (indexPath.row < room.numDryerOpen + room.numDryerRunning) {
         cell.bgImageColor = UIColor.whiteGrey
         cell.bgImage = UIImage(named: "dryer_busy")
         if (indexPath.row - room.numDryerOpen) < room.remainingTimeDryers.count {
         let time = room.remainingTimeDryers[indexPath.row - room.numDryerOpen]
         cell.timerText = "\(time)"
         }
         } else {
         cell.bgImageColor = UIColor.clear
         cell.bgImage = UIImage(named: "dryer_broken")
         cell.timerText = ""
         }
         }
         }*/
        if let room = room {
            if cellMachineTypeWasher {
                if (indexPath.row < room.numWasherRunning) {
                    cell.bgImageColor = UIColor.clear
                    cell.bgImage = UIImage(named: "washer_busy")
                    if indexPath.row < room.remainingTimeWashers.count {
                        let time = room.remainingTimeWashers[indexPath.row]
                        cell.timerText = "\(time)"
                    } else {
                        cell.timerText = "" // need to cache to prevent empty cell from copying time of non-empty
                    }
                } else if (indexPath.row < room.numWasherOpen + room.numWasherRunning) {
                    cell.bgImageColor = UIColor.clear
                    cell.bgImage = UIImage(named: "washer_open")
                    cell.timerText = ""
                } else {
                    cell.bgImageColor = UIColor.clear
                    cell.bgImage = UIImage(named: "washer_broken")
                    cell.timerText = ""
                }
            } else {
                if (indexPath.row < room.numDryerRunning) {
                    cell.bgImageColor = UIColor.clear
                    cell.bgImage = UIImage(named: "dryer_busy")
                    if indexPath.row < room.remainingTimeDryers.count {
                        let time = room.remainingTimeDryers[indexPath.row]
                        cell.timerText = "\(time)"
                    } else {
                        cell.timerText = "" // need to cache to prevent empty cell from copying time of non-empty
                    }
                } else if (indexPath.row < room.numDryerOpen + room.numDryerRunning) {
                    cell.bgImageColor = UIColor.clear
                    cell.bgImage = UIImage(named: "dryer_open")
                    cell.timerText = ""
                } else {
                    cell.bgImageColor = UIColor.clear
                    cell.bgImage = UIImage(named: "dryer_broken")
                    cell.timerText = ""
                }
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 55, height: 55)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 5, left: 20, bottom: 5, right: 5)
    }
}

// MARK: - Extension functions to delete cells, expand graph view

extension LaundryCell {
    @objc fileprivate func deleteRoom() {
        delegate?.deleteLaundryCell(for: room)
    }
    
    @objc fileprivate func toggleGraph() {
        self.isDryerGraph = !isDryerGraph
        scrollableGraphView?.reload()
    }
    
    /*
    @objc fileprivate func toggleGraph() {
        delegate?.toggleGraphView(self)
    }*/
    
    /*
    This code will programmatically expand the cell to include a graph view
    func addGraphView() {
        // GraphView (Only exists when toggled)
        if (isExpanded) {
            bgView.addSubview(graphView)
            _ = graphView.anchor(washersDryersView.bottomAnchor, left: bgView.leftAnchor,
                                 bottom: bottomAnchor, right: bgView.rightAnchor,
                                 topConstant: 10, leftConstant: 10, bottomConstant: 10, rightConstant: 10,
                                 widthConstant: 0, heightConstant: 0)
            graphView.initializeGraph()
            graphView.animateDataRectangles(withDuration: 2.0)
        }
    }
    
    func removeGraphView() {
        if (isExpanded) {
            graphView.clearGraph()
            graphView.removeConstraints(graphView.constraints)
            graphView.removeFromSuperview()
        }
    }*/
}
