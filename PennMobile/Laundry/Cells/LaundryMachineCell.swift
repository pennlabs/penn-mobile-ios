//
//  LaundryMachineCell.swift
//  PennMobile
//
//  Created by Dominic Holmes on 10/28/17.
//  Copyright © 2017 PennLabs. All rights reserved.
//

import UIKit

class LaundryMachineCell: UICollectionViewCell {
    static let identifier = "laundryMachineCell"
    
    var machine: LaundryMachine! {
        didSet {
            if let machine = machine {
                updateCell(with: machine)
            }
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
        if #available(iOS 13.0, *) {
            iv.image = UIImage(named: "bell")?.withTintColor(.baseYellow)
        } else {
            iv.image = UIImage(named: "bell")
        }
        iv.isHidden = true
        return iv
    }()
    
    private let timerLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.font = .primaryInformationFont
        label.textColor = .labelSecondary
        label.layer.cornerRadius = 4
        label.layer.masksToBounds = true
        label.textAlignment = .center
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.clear
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
                               topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0,
                               widthConstant: 0, heightConstant: 0)
        
        self.addSubview(bellView)
        bellView.centerYAnchor.constraint(equalTo: topAnchor).isActive = true
        _ = bellView.anchor(nil, left: nil, bottom: nil, right: rightAnchor, topConstant: -8, leftConstant: 0, bottomConstant: 0, rightConstant: -8, widthConstant: 20, heightConstant: 20)
    }
    
    func updateCell(with machine: LaundryMachine) {
        let typeStr = machine.isWasher ? "washer" : "dryer"
        let statusStr: String
        switch machine.status {
        case .open:
            statusStr = "open"
        case .running:
            statusStr = "busy"
        case .offline,
             .outOfOrder:
            statusStr = "broken"
        }
        
        bgImageView.image = UIImage(named: "\(typeStr)_\(statusStr)")
        
        if machine.status == .running && machine.timeRemaining > 0 {
            timerLabel.text = "\(machine.timeRemaining)"
        } else {
            timerLabel.text = ""
        }
        
        bellView.isHidden = !machine.isUnderNotification()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
