//
//  BuildingImageCell.swift
//  PennMobile
//
//  Created by dominic on 6/19/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//

import UIKit

class BuildingImageCell: UITableViewCell {
    
    static let identifier = "buildingImageCell"
    static let cellHeight: CGFloat = 188

    var buildingImage: UIImage! {
        didSet {
            setupCell(with: buildingImage)
        }
    }

    fileprivate var buildingImageView: UIImageView!

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
extension BuildingImageCell {
    fileprivate func setupCell(with buildingImage: UIImage) {
        buildingImageView.image = buildingImage
    }
}

// MARK: - Initialize and Prepare UI
extension BuildingImageCell {

    fileprivate func prepareUI() {
        prepareImageView()
    }

    fileprivate func prepareImageView() {
        buildingImageView = getBuildingImageView()
        addSubview(buildingImageView)

        buildingImageView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        buildingImageView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        buildingImageView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        buildingImageView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }
}

//MARK: - Define UI Elements
extension BuildingImageCell {
    fileprivate func getBuildingImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }
}
