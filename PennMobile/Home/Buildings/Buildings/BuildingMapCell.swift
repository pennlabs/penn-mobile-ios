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
    
    override var venue: DiningVenue! {
        didSet {
            setupCell(with: venue)
        }
    }
    
    fileprivate let safeInsetValue: CGFloat = 14
    fileprivate var safeArea: UIView!
    fileprivate var mapView: MKMapView!
    
    // MARK: - Init
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        prepareUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Setup Cell
extension BuildingMapCell {
    
    fileprivate func setupCell(with venue: DiningVenue) {
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
            safeArea.leadingAnchor.constraint(equalTo: leadingAnchor, constant: safeInsetValue),
            safeArea.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -safeInsetValue),
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
            mapView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor),
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
        
        // Set default loc. to Penn's coordinates: 39.9522° N, -75.1932° W
        mv.setCenter(CLLocationCoordinate2DMake(39.9522, -75.1932), animated: true)
        
        return mv
    }
}
