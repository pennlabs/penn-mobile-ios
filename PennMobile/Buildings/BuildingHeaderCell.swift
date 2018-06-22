//
//  BuildingHeaderCell.swift
//  PennMobile
//
//  Created by dominic on 6/21/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//

import UIKit

class BuildingHeaderCell: UITableViewCell {
    
    static let identifier = "BuildingHeaderCell"
    static let cellHeight: CGFloat = 188
    
    var venue: DiningVenue! {
        didSet {
            setupCell(with: venue)
        }
    }
    
    fileprivate var buildingHeaderView: UIImageView!
    
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
extension BuildingHeaderCell {
    fileprivate func setupCell(with venue: DiningVenue) {
        buildingHeaderView.image = UIImage(named: venue.name.rawValue.folding(options: .diacriticInsensitive, locale: .current))
    }
}

// MARK: - Initialize and Prepare UI
extension BuildingHeaderCell {
    
    fileprivate func prepareUI() {
        prepareHeaderView()
    }
    
    fileprivate func prepareHeaderView() {
        buildingHeaderView = getBuildingHeaderView()
        addSubview(buildingHeaderView)
        
        buildingHeaderView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        buildingHeaderView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        buildingHeaderView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        buildingHeaderView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }
}

//MARK: - Define UI Elements
extension BuildingHeaderCell {
    fileprivate func getBuildingHeaderView() -> UIImageView {
        let imageView = UIHeaderView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = .blue
        return imageView
    }
}

