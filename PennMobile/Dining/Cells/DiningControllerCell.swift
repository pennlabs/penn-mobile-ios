//
//  DiningControllerCell.swift
//  PennMobile
//
//  Created by Josh Doman on 3/30/17.
//  Copyright © 2017 PennLabs. All rights reserved.
//

import UIKit

class DiningControllerCell: UITableViewCell {
    
    var diningHall: DiningHall! {
        didSet {
            diningImage.image = UIImage(named: diningHall.name.folding(options: .diacriticInsensitive, locale: .current))
            label.text = diningHall.name
            if let times = diningHall.times {
                updateTimeLabel(with: times)
            }
        }
    }
    
    private let diningImage: UIImageView = {
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
        return label
    }()
    
    private let shadowLayer = ShadowView()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
                
        setupView()
    }
    
    private func setupView() {
        //addSubview(shadowLayer)
        addSubview(mainBackground)
        
        //shadowLayer.anchorToTop(topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor)
        mainBackground.anchorToTop(topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor)
        
        mainBackground.addSubview(diningImage)
        mainBackground.addSubview(label)
        mainBackground.addSubview(timesLabel)
        
        _ = diningImage.anchor(mainBackground.topAnchor, left: mainBackground.leftAnchor, bottom: mainBackground.bottomAnchor, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        diningImage.widthAnchor.constraint(equalTo: mainBackground.widthAnchor, multiplier: 0.5).isActive = true
        
        label.topAnchor.constraint(equalTo: mainBackground.centerYAnchor, constant: -4).isActive = true
        label.leftAnchor.constraint(equalTo: diningImage.rightAnchor, constant: 20).isActive = true
        
        _ = timesLabel.anchor(label.bottomAnchor, left: label.leftAnchor, bottom: nil, right: nil, topConstant: 8, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
    }
    
    private func setIsOpen(isOpen: Bool) {
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func updateTimeLabel(with times: [OpenClose]) {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "h:mma"
        formatter.timeZone = TimeZone(abbreviation: "GMT")!
        formatter.amSymbol = "a"
        formatter.pmSymbol = "p"
        
        var firstOpenClose = true
        var timesString = ""
        
        for open_close in times {
            if open_close.open.minutes == 0 {
                formatter.dateFormat = times.count > 1 ? "h" : "ha"
            } else {
                formatter.dateFormat = times.count > 1 ? "h:mm" : "h:mma"
            }
            let open = formatter.string(from: open_close.open)
            
            if open_close.close.minutes == 0 {
                formatter.dateFormat = times.count > 1 ? "h" : "ha"
            } else {
                formatter.dateFormat = times.count > 1 ? "h:mm" : "h:mma"
            }
            let close = formatter.string(from: open_close.close)
            
            if firstOpenClose {
                firstOpenClose = false
            } else {
                timesString += "  |  "
            }
            timesString += "\(open) - \(close)"
        }
        
        if times.isEmpty {
            timesString = "CLOSED"
        }
        
        timesLabel.text = timesString
    }
    
}
