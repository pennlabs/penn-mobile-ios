//
//  GSRColorCell.swift
//  PennMobile
//
//  Created by Daniel Salib on 10/25/19.
//  Copyright © 2019 PennLabs. All rights reserved.
//

import UIKit

class GSRColorCell: UICollectionViewCell {
    
    static let identifier = "groupColorCell"
    
//    var timeSlot: GSRTimeSlot! {
//        didSet {
//            startLabel.text = format(date: timeSlot.startTime)
//            endLabel.text = format(date: timeSlot.endTime)
//            backgroundColor = timeSlot.isAvailable ? UIColor.interactionGreen : UIColor.secondaryInformationGrey
//        }
//    }
    
    var color: UIColor! {
        didSet {
            colorView.backgroundColor = color
        }
    }

    private let colorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalToConstant: 36).isActive = true
        view.widthAnchor.constraint(equalToConstant: 36).isActive = true
        view.layer.cornerRadius = 18
        view.layer.masksToBounds = false
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    private func setupView() {
        addSubview(colorView)
        
        colorView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        colorView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        
//        _ = startLabel.anchor(topAnchor, left: nil, bottom: nil, right: nil, topConstant: 8, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
//        startLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
//
//        _ = endLabel.anchor(nil, left: nil, bottom: bottomAnchor, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: 8, rightConstant: 0, widthConstant: 0, heightConstant: 0)
//        endLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
    }
    
    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
        super.init(coder: coder)
    }
}
