//
//  AboutPageCollectionViewCell.swift
//  PennMobile
//
//  Created by Marta García Ferreiro on 10/26/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//

import UIKit

class AboutPageCollectionViewCell: UICollectionViewCell {
    
    let profileImage: UIImageView = {
        let image = UIImageView()
        image.layer.cornerRadius = 83/2
        image.clipsToBounds = true
        image.image = UIImage()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.widthAnchor.constraint(equalToConstant: 83).isActive = true
        image.heightAnchor.constraint(equalToConstant: 83).isActive = true
        image.backgroundColor = .grey4
        image.contentMode = .scaleAspectFill
        return image
    }()
    
    let name: UILabel = {
        let label = UILabel()
        label.font = .secondaryTitleFont
        label.textColor = UIColor.labelSecondary
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        label.numberOfLines = 1
        return label
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        let stackView = UIStackView(arrangedSubviews: [profileImage, name])
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.alignment = .center
        stackView.spacing = 2
        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)
        stackView.widthAnchor.constraint(equalToConstant: 90).isActive = true
        stackView.heightAnchor.constraint(equalToConstant: 105).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
