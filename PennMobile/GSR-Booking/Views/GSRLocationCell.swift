//
//  GSRLocationCell.swift
//  PennMobile
//
//  Created by Josh Doman on 4/1/19.
//  Copyright © 2019 PennLabs. All rights reserved.
//

import UIKit
import Kingfisher

class GSRLocationCell: UITableViewCell {
    
    static let identifier = "locationCell"
    static let cellHeight: CGFloat = 98
    
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
            if let url = URL(string: "https://s3.us-east-2.amazonaws.com/labs.api/gsr/lid-\(location.lid)-gid-\(location.gid ?? location.lid).jpg") {
                buildingImage.kf.setImage(with: url)
            }
        }
    }
        
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
        backgroundColor = .clear
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
        locationLabel.textColor = UIColor.labelPrimary
        locationLabel.textAlignment = .left
        locationLabel.numberOfLines = 2
        
        addSubview(locationLabel)
        _ = locationLabel.anchor(nil, left: buildingImage.rightAnchor, bottom: nil, right: rightAnchor, topConstant: 0, leftConstant: 20, bottomConstant: 0, rightConstant: 25, widthConstant: 0, heightConstant: 0)
        locationLabel.centerYAnchor.constraint(equalTo: buildingImage.centerYAnchor).isActive = true
    }
}
