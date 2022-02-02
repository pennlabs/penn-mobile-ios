//
//  LaundryCell.swift
//  PennMobile
//
//  Created by Dominic Holmes on 9/30/17.
//  Copyright © 2017 PennLabs. All rights reserved.
//

import UIKit
import ScrollableGraphView

// MARK: - Laundry Cell Delegate

protocol LaundryCellDelegate: AnyObject, LaundryMachineCellTappable {
    func deleteLaundryCell(for room: LaundryRoom)
}

// MARK: - Laundry Cell

class LaundryCell: UITableViewCell {

    weak var delegate: LaundryCellDelegate?

    var room: LaundryRoom! {
        didSet {
            roomLabel.text = room.building.uppercased()
            roomFloorLabel.text = room.name
            washerCollectionView?.reloadData()
            dryerCollectionView?.reloadData()
            reloadGraphDataIfNeeded(oldRoom: oldValue, newRoom: room)
        }
    }

    var usageData: [Double]!
    var graphData = Array(repeating: 0.0, count: LaundryCell.numberOfDataPointsInGraph)

    // Number of datapoints displayed in the graph
    internal static let numberOfDataPointsInGraph = 27

    // Space between data points
    internal let dataPointSpacing = 30

    internal let safeInsetValue: CGFloat = 14

    // MARK: - Define UI Element Variables

    fileprivate var washerCollectionView: UICollectionView?
    fileprivate var dryerCollectionView: UICollectionView?

    fileprivate let collectionCellId = "cellId"

    internal var scrollableGraphView: ScrollableGraphView?
    internal var dottedLineShapeLayer: CAShapeLayer?

    fileprivate let bgView: UIView = {
        let bg = UIView()

        // corner radius for cell. a seperate variable controls corner radius of the Graph
        bg.layer.cornerRadius = 10.0

        //bg.layer.borderWidth = 0.0
        bg.layer.borderWidth = 1.0
        bg.layer.borderColor = UIColor.clear.cgColor

        // shadow
        bg.layer.shadowColor = UIColor.black.cgColor
        //bg.layer.shadowColor = UIColor.clear.cgColor

        bg.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        bg.layer.shadowOpacity = 0.25
        bg.layer.shadowRadius = 4.0
        bg.backgroundColor = UIColor.uiCardBackground

        return bg
    }()

    fileprivate lazy var xButton: UIButton = {
        let xb = UIButton()
        xb.backgroundColor = UIColor.clear
        xb.contentMode = .scaleAspectFill
        xb.clipsToBounds = true
        xb.layer.cornerRadius = 20
        xb.layer.masksToBounds = true
        xb.setBackgroundImage(UIImage(named: "x_button"), for: UIControl.State.normal)
        xb.setBackgroundImage(UIImage(named: "x_button_selected"), for: .selected)
        xb.setBackgroundImage(UIImage(named: "x_button_selected"), for: .highlighted)
        xb.addTarget(self, action: #selector(deleteRoom), for: .touchUpInside)
        return xb
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
        label.font = .secondaryTitleFont
        label.textColor = .labelSecondary
        label.textAlignment = .left
        return label
    }()

    fileprivate let roomFloorLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.font = .primaryTitleFont
        label.textColor = .labelPrimary
        label.textAlignment = .left
        return label
    }()

    fileprivate let washersLabel: UILabel = {
        let label = UILabel()
        label.text = "Washers"
        label.font = .secondaryInformationFont
        label.textColor = .labelPrimary
        label.layer.cornerRadius = 4
        label.layer.masksToBounds = true
        label.textAlignment = .left
        return label
    }()

    fileprivate let dryersLabel: UILabel = {
        let label = UILabel()
        label.text = "Dryers"
        label.font = .secondaryInformationFont
        label.textColor = .labelPrimary
        label.layer.cornerRadius = 4
        label.layer.masksToBounds = true
        label.textAlignment = .left
        return label
    }()

    fileprivate let numWashersLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.font = .primaryInformationFont
        label.textColor = .labelSecondary
        label.layer.cornerRadius = 4
        label.layer.masksToBounds = true
        label.textAlignment = .right
        return label
    }()

    fileprivate let numDryersLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.font = .primaryInformationFont
        label.textColor = .labelSecondary
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

    fileprivate let graphLabel: UILabel = {
        let label = UILabel()
        label.text = "Popular Times"
        label.font = .secondaryInformationFont
        label.textColor = .labelPrimary
        label.layer.cornerRadius = 4
        label.layer.masksToBounds = true
        label.textAlignment = .left
        return label
    }()

    let graphDayLabel: UILabel = {
        let label = UILabel()
        let day = Date.currentDayOfWeek
        label.text = day
        label.font = .primaryInformationFont
        label.textColor = .labelSecondary
        label.layer.cornerRadius = 4
        label.layer.masksToBounds = true
        label.textAlignment = .right
        return label
    }()

    fileprivate let safeArea: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    fileprivate let dividerLine: UIView = {
        let view = UIView()
        view.backgroundColor = .grey5
        view.layer.cornerRadius = 2.0
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    // MARK: - Init

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

// MARK: - Layout Views, Constraints

extension LaundryCell {
    fileprivate func setupViews() {

        for eachView in self.subviews {
            eachView.removeFromSuperview()
        }

        addSubview(bgView)

        // BackgroundImageView
        _ = bgView.anchor(topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor,
                          topConstant: 20, leftConstant: 20, bottomConstant: 0, rightConstant: 20,
                          widthConstant: 0, heightConstant: 0)

        bgView.addSubview(safeArea)
        safeArea.leadingAnchor.constraint(equalTo: bgView.leadingAnchor, constant: safeInsetValue).isActive = true
        safeArea.trailingAnchor.constraint(equalTo: bgView.trailingAnchor, constant: -safeInsetValue).isActive = true
        safeArea.topAnchor.constraint(equalTo: bgView.topAnchor, constant: safeInsetValue).isActive = true
        safeArea.bottomAnchor.constraint(equalTo: bgView.bottomAnchor, constant: -safeInsetValue).isActive = true

        bgView.addSubview(roomLabel)
        bgView.addSubview(roomFloorLabel)
        bgView.addSubview(washersDryersView)
        bgView.addSubview(dividerLine)
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

        bgView.addSubview(graphLabel)
        bgView.addSubview(graphDayLabel)

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
        _ = washersDryersView.anchor(dividerLine.bottomAnchor, left: bgView.leftAnchor,
                                     bottom: nil, right: bgView.rightAnchor,
                                     topConstant: 16, leftConstant: 0, bottomConstant: 10, rightConstant: 0,
                                     widthConstant: 0, heightConstant: 200.0)

        dividerLine.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor).isActive = true
        dividerLine.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor).isActive = true
        dividerLine.topAnchor.constraint(equalTo: roomFloorLabel.bottomAnchor, constant: 14).isActive = true
        dividerLine.heightAnchor.constraint(equalToConstant: 2).isActive = true

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
        roomFloorLabel.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor).isActive = true
        roomFloorLabel.topAnchor.constraint(equalTo: roomLabel.bottomAnchor, constant: 10).isActive = true

        // Room Label (Building name)
        roomLabel.translatesAutoresizingMaskIntoConstraints = false
        roomLabel.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor).isActive = true
        roomLabel.topAnchor.constraint(equalTo: safeArea.topAnchor).isActive = true

        // "Washers" Label
        washersLabel.translatesAutoresizingMaskIntoConstraints = false
        washersLabel.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor).isActive = true
        washersLabel.topAnchor.constraint(
            equalTo: washerView.topAnchor,
            constant: 8).isActive = true

        // "Num Washers" Label
        numWashersLabel.translatesAutoresizingMaskIntoConstraints = false
        numWashersLabel.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor).isActive = true
        numWashersLabel.centerYAnchor.constraint(
            equalTo: washersLabel.centerYAnchor,
            constant: 0).isActive = true

        // "Dryers" Label
        dryersLabel.translatesAutoresizingMaskIntoConstraints = false
        dryersLabel.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor).isActive = true
        dryersLabel.topAnchor.constraint(
            equalTo: dryerView.topAnchor,
            constant: 2).isActive = true

        // "Num Dryers" Label
        numDryersLabel.translatesAutoresizingMaskIntoConstraints = false
        numDryersLabel.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor).isActive = true
        numDryersLabel.centerYAnchor.constraint(
            equalTo: dryersLabel.centerYAnchor,
            constant: 0).isActive = true

        // "Busy times on _" Graph Label
        graphLabel.translatesAutoresizingMaskIntoConstraints = false
        graphLabel.leadingAnchor.constraint(
            equalTo: safeArea.leadingAnchor).isActive = true
        graphLabel.topAnchor.constraint(
            equalTo: graphViewContainer.topAnchor,
            constant: 0).isActive = true

        graphDayLabel.translatesAutoresizingMaskIntoConstraints = false
        graphDayLabel.trailingAnchor.constraint(
            equalTo: safeArea.trailingAnchor).isActive = true
        graphDayLabel.topAnchor.constraint(
            equalTo: graphLabel.topAnchor).isActive = true

    }
}

// MARK: - Machine CollectionView Delegate, Datasource

extension LaundryCell: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate {
    fileprivate func generateCollectionView(_ frame: CGRect) -> UICollectionView {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: frame, collectionViewLayout: flowLayout)
        collectionView.register(LaundryMachineCell.self, forCellWithReuseIdentifier: collectionCellId)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = UIColor.clear
        collectionView.showsHorizontalScrollIndicator = false
        return collectionView
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let machineArray = collectionView == washerCollectionView ? room.washers : room.dryers
        numWashersLabel.text = "\(room.washers.numberOpenMachines()) of \(room.washers.count) open"
        numDryersLabel.text = "\(room.dryers.numberOpenMachines()) of \(room.dryers.count) open"
        return machineArray.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: collectionCellId, for: indexPath as IndexPath) as! LaundryMachineCell
        let machineArray = collectionView == washerCollectionView ? room.washers : room.dryers
        cell.machine = machineArray[indexPath.row]
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 50, height: 50)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 5, left: 20, bottom: 5, right: 5)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let machineArray = collectionView == washerCollectionView ? room.washers : room.dryers
        let machine = machineArray[indexPath.row]
        if machine.status == .running && machine.timeRemaining > 0 {
            delegate?.handleMachineCellTapped(for: machineArray[indexPath.item]) {
                DispatchQueue.main.async {
                    collectionView.reloadData()
                }
            }
        }
    }

    func reloadData() {
        washerCollectionView?.reloadData()
        dryerCollectionView?.reloadData()
        reloadDottedLineLayer()
    }
}

// MARK: - Deletion

extension LaundryCell {
    @objc fileprivate func deleteRoom() {
        delegate?.deleteLaundryCell(for: room)
    }
}
