//
//  DiningControllerCell.swift
//  PennMobile
//
//  Created by Josh Doman on 3/30/17.
//  Copyright © 2017 PennLabs. All rights reserved.
//

import UIKit

class DiningCell: UITableViewCell {
    static let identifier = "diningCell"
    static let cellHeight: CGFloat = 112
    
    var venue: DiningVenue! {
        didSet {
            venueImage.image = UIImage(named: venue.name.folding(options: .diacriticInsensitive, locale: .current))
            label.text = venue.name
            
            updateTimeLabel(with: venue.times)
        }
    }
    
    private let venueImage: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    
    private let mainBackground: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(r: 247, g: 247, b: 247)
        return v
    }()
    
    private let label: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "HelveticaNeue", size: 15.5)
        label.textColor = UIColor.warmGrey
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let openLabel: UILabel = {
        let label = UILabel()
        label.text = "Open"
        label.font = UIFont(name: "HelveticaNeue-Light", size: 13)
        label.textColor = .white
        label.backgroundColor = UIColor.coral
        label.layer.cornerRadius = 4
        label.layer.masksToBounds = true
        label.textAlignment = .center
        return label
    }()
    
    private let timesLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.warmGrey
        label.font = UIFont(name: "HelveticaNeue-Light", size: 12)
        label.textAlignment = .left
        label.numberOfLines = 2
        return label
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupView()
    }
    
    private func setupView() {
        addSubview(mainBackground)
        
        mainBackground.anchorToTop(topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor)
        
        mainBackground.addSubview(venueImage)
        mainBackground.addSubview(label)
        mainBackground.addSubview(timesLabel)
        
        _ = venueImage.anchor(mainBackground.topAnchor, left: mainBackground.leftAnchor, bottom: mainBackground.bottomAnchor, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        venueImage.widthAnchor.constraint(equalTo: mainBackground.widthAnchor, multiplier: 0.5).isActive = true
        
        label.topAnchor.constraint(equalTo: mainBackground.centerYAnchor, constant: -4).isActive = true
        label.leftAnchor.constraint(equalTo: venueImage.rightAnchor, constant: 20).isActive = true
        
        _ = timesLabel.anchor(label.bottomAnchor, left: label.leftAnchor, bottom: nil, right: rightAnchor, topConstant: 8, leftConstant: 0, bottomConstant: 0, rightConstant: 6, widthConstant: 0, heightConstant: 0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func updateTimeLabel(with times: [OpenClose]?) {
        timesLabel.text = times?.strFormat
        
        if let times = times, times.count > 3 {
            timesLabel.shrinkUntilFits(numberOfLines: 1, increment: 0.5)
        } else {
            timesLabel.font = UIFont(name: "HelveticaNeue-Light", size: 12)
        }
    }
    
}

