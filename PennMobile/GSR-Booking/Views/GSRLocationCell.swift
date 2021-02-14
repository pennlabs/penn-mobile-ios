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
    static let cellHeight: CGFloat = 110
    
    var location: GSRLocation! {
        didSet {
            locationLabel.text = location.name
            if let url = URL(string: "https://s3.us-east-2.amazonaws.com/labs.api/gsr/lid-\(location.lid)-gid-\(location.gid ?? location.lid).jpg") {
                buildingImageView.kf.setImage(with: url)
            }
        }
    }
        
    // MARK: - UI Elements
    fileprivate var safeArea: UIView!
    fileprivate var locationLabel: UILabel!
    fileprivate var serviceLabel: UILabel!
    fileprivate var buildingImageView: UIImageView!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.prepareUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Prepare UI
extension GSRLocationCell {
    fileprivate func prepareUI() {
        backgroundColor = .clear
        accessoryType = .disclosureIndicator
        prepareSafeArea()
        prepareImageView()
        prepareLabels()
    }
    
    // MARK: Safe Area
    fileprivate func prepareSafeArea() {
        safeArea = UIView()
        addSubview(safeArea)
        
        safeArea.snp.makeConstraints { (make) in
            make.leading.equalTo(self).offset(pad)
            make.trailing.equalTo(self).offset(-pad * 2)
            make.top.equalTo(self).offset(pad)
            make.bottom.equalTo(self).offset(-pad)
        }
    }
    
    // MARK: ImageView
    fileprivate func prepareImageView() {
        buildingImageView = getBuildingImageView()
        addSubview(buildingImageView)
        
        buildingImageView.snp.makeConstraints { (make) in
            make.width.equalTo(134)
            make.height.equalTo(86)
            make.leading.equalTo(safeArea)
            make.centerY.equalTo(safeArea)
        }
    }
    
    // MARK: Labels
    fileprivate func prepareLabels() {
        locationLabel = getLocationLabel()
        addSubview(locationLabel)

        locationLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(buildingImageView)
            make.leading.equalTo(buildingImageView.snp.trailing).offset(pad)
            make.trailing.equalTo(safeArea)
        }
    }
}

// MARK: - Define UI Elements
extension GSRLocationCell {
    
    fileprivate func getBuildingImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.backgroundColor = .grey2
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 5.0
        return imageView
    }
    
    fileprivate func getLocationLabel() -> UILabel {
        let label = UILabel()
        label.font = .interiorTitleFont
        label.textColor = .labelPrimary
        label.textAlignment = .left
        label.shrinkUntilFits()
        return label
    }
}
