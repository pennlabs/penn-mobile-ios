//
//  GSRLocationCell.swift
//  PennMobile
//
//  Created by Josh Doman on 4/1/19.
//  Copyright © 2019 PennLabs. All rights reserved.
//

import Foundation
import UIKit

class GSRLocationCell: UITableViewCell {
    
    static let identifier = "locationCell"
    static let cellHeight: CGFloat = 100
    
    var isHomePageCell: Bool = false {
        didSet {
            if isHomePageCell {
                if buildingImageLeftConstraint != nil {
                    buildingImage.removeConstraint(buildingImageLeftConstraint)
                    buildingImageLeftConstraint = buildingImage.leftAnchor.constraint(equalTo: leftAnchor)
                    buildingImageLeftConstraint.isActive = true
                }
            }
        }
    }
    
    var location: GSRLocation! {
        didSet {
            locationLabel.text = location.name
            
            if (location.lid == 1086 && location.gid != 1889){
                let imageName = "lid-\(location.lid)"
                buildingImage.image = UIImage(named: imageName)
            }
            else if let gid = location.gid {
                let imageName = "lid-\(location.lid)-gid-\(gid)"
                buildingImage.image = UIImage(named: imageName)
            }
        }
    }
    
    var delegate: ReservationCellDelegate!
    
    fileprivate var locationLabel: UILabel!
    fileprivate var buildingImage: UIImageView!
    
    fileprivate var buildingImageLeftConstraint: NSLayoutConstraint!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.prepareUI()
        self.accessoryType = .disclosureIndicator
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Prepare UI
extension GSRLocationCell {
    fileprivate func prepareUI() {
        prepareBuildingImage()
        prepareLocationLabel()
    }
    
    func prepareBuildingImage() {
        buildingImage = UIImageView()
        buildingImage.translatesAutoresizingMaskIntoConstraints = false
        buildingImage.contentMode = .scaleAspectFill
        buildingImage.clipsToBounds = true
        buildingImage.layer.cornerRadius = 8.0
        addSubview(buildingImage)
        buildingImageLeftConstraint = buildingImage.anchor(topAnchor, left: leftAnchor, bottom: bottomAnchor, right: nil, topConstant: 8, leftConstant: 25, bottomConstant: 8, widthConstant: 139, heightConstant: 0)[1]
    }
    
    private func prepareLocationLabel() {
        locationLabel = UILabel()
        locationLabel.font = UIFont.interiorTitleFont
        locationLabel.textColor = UIColor.primaryTitleGrey
        locationLabel.textAlignment = .left
        locationLabel.numberOfLines = 2
        
        addSubview(locationLabel)
        _ = locationLabel.anchor(nil, left: buildingImage.rightAnchor, bottom: nil, right: rightAnchor, topConstant: 0, leftConstant: 20, bottomConstant: 0, rightConstant: 25, widthConstant: 0, heightConstant: 0)
        locationLabel.centerYAnchor.constraint(equalTo: buildingImage.centerYAnchor).isActive = true
    }
}
