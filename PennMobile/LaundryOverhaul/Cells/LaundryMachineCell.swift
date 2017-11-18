//
//  LaundryMachineCell.swift
//  PennMobile
//
//  Created by Dominic Holmes on 10/28/17.
//  Copyright © 2017 PennLabs. All rights reserved.
//

import UIKit

class LaundryMachineCell: UICollectionViewCell {
    
    var isUnderNotification: Bool = false {
        didSet {
            bellView.isHidden = !isUnderNotification
        }
    }
    
    var bgImage: UIImage? {
        didSet {
            bgImageView.image = bgImage
        }
    }
    
    var bgImageColor: UIColor? {
        didSet {
            bgImageView.backgroundColor = bgImageColor == nil ? .clear : bgImageColor!
        }
    }
    
    var timerText: String? {
        didSet {
            timerLabel.text = timerText
        }
    }
    
    private let bgImageView: UIImageView = {
        let bg = UIImageView()
        bg.backgroundColor = .clear
        bg.layer.cornerRadius = 25
        return bg
    }()
    
    private let bellView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "bell")
        iv.isHidden = true
        return iv
    }()
    
    private let timerLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.font = UIFont(name: "HelveticaNeue-Light", size: 18)
        label.textColor = UIColor.darkGray
        label.layer.cornerRadius = 4
        label.layer.masksToBounds = true
        label.textAlignment = .center
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        isUnderNotification = false
        
        setupViews()
    }
    
    func setupViews() {
        self.addSubview(bgImageView)
        _ = bgImageView.anchor(topAnchor, left: leftAnchor,
                                     bottom: bottomAnchor, right: rightAnchor,
                                     topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0,
                                     widthConstant: 0, heightConstant: 0)
        self.addSubview(timerLabel)
        _ = timerLabel.anchor(topAnchor, left: leftAnchor,
                               bottom: bottomAnchor, right: rightAnchor,
                               topConstant: -10, leftConstant: 0, bottomConstant: 0, rightConstant: 0,
                               widthConstant: 0, heightConstant: 0)
        
        self.addSubview(bellView)
        bellView.centerYAnchor.constraint(equalTo: topAnchor).isActive = true
        _ = bellView.anchor(nil, left: nil, bottom: nil, right: rightAnchor, topConstant: -8, leftConstant: 0, bottomConstant: 0, rightConstant: -8, widthConstant: 20, heightConstant: 20)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
