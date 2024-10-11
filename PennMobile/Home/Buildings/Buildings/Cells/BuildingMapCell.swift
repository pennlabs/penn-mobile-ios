//
//  BuildingMapCell.swift
//  PennMobile
//
//  Created by dominic on 6/21/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//

import UIKit
import MapKit

class BuildingMapCell: BuildingCell {

    static let identifier = "BuildingMapCell"
    static let cellHeight: CGFloat = 240

    var building: BuildingMapDisplayable! {
        didSet {
            setupCell(with: building)
        }
    }

    fileprivate let safeInsetValue: CGFloat = 14
    fileprivate var safeArea: UIView!
    fileprivate var mapView: MKMapView!

    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        prepareUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Setup Cell
extension BuildingMapCell {

    fileprivate func setupCell(with building: BuildingMapDisplayable) {
        mapView.setRegion(building.getRegion(), animated: false)
        mapView.addAnnotation(building.getAnnotation())
    }
}

// MARK: - Initialize and Prepare UI
extension BuildingMapCell {

    fileprivate func prepareUI() {
        prepareSafeArea()
        prepareMapView()
    }

    // MARK: Safe Area
    fileprivate func prepareSafeArea() {
        safeArea = getSafeAreaView()
        addSubview(safeArea)
        NSLayoutConstraint.activate([
            safeArea.leadingAnchor.constraint(equalTo: leadingAnchor, constant: safeInsetValue * 2),
            safeArea.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -safeInsetValue * 2),
            safeArea.topAnchor.constraint(equalTo: topAnchor, constant: safeInsetValue),
            safeArea.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -safeInsetValue)
            ])
    }

    // MARK: Map View
    fileprivate func prepareMapView() {
        mapView = getMapView()
        addSubview(mapView)
        NSLayoutConstraint.activate([
            mapView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            mapView.topAnchor.constraint(equalTo: safeArea.topAnchor),
            mapView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            mapView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor)
            ])
    }

    fileprivate func getSafeAreaView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    fileprivate func getMapView() -> MKMapView {
        let mv = MKMapView(frame: safeArea.frame)
        mv.translatesAutoresizingMaskIntoConstraints = false
        mv.layer.cornerRadius = 10.0
        mv.isScrollEnabled = false

        mv.setRegion(PennLocation.shared.getDefaultRegion(at: .close), animated: false)

        return mv
    }
}
