//
//  HourCell.swift
//  PennMobile
//
//  Created by Josh Doman on 4/20/17.
//  Copyright © 2017 PennLabs. All rights reserved.
//

import UIKit

class HourCell: UICollectionViewCell {
    
    static let identifier = "hourCell"
    
    var hour: GSRHour! {
        didSet {
            startLabel.text = hour.start
            endLabel.text = hour.end
        }
    }
    
    private let startLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    
    private let endLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    
    private let toLabel: UILabel = {
        let label = UILabel()
        label.text = "to"
        label.font = UIFont.systemFont(ofSize: 10)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = Colors.green.color()
        
        setupView()
    }
    
    private func setupView() {
        addSubview(startLabel)
        addSubview(endLabel)
        addSubview(toLabel)
        
        toLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        toLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        
        _ = startLabel.anchor(topAnchor, left: nil, bottom: nil, right: nil, topConstant: 4, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        startLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        
        _ = endLabel.anchor(nil, left: nil, bottom: bottomAnchor, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: 4, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        endLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
