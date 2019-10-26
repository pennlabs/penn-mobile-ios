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
    var colorView: UIView!
    var borderColor: UIColor = .black
    
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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    private func setupView() {
        colorView = UIView()
        colorView.translatesAutoresizingMaskIntoConstraints = false
        colorView.heightAnchor.constraint(equalToConstant: 36).isActive = true
        colorView.widthAnchor.constraint(equalToConstant: 36).isActive = true
        colorView.layer.cornerRadius = 18
        colorView.layer.masksToBounds = false
        colorView.layer.borderWidth = 0
        colorView.layer.borderColor = borderColor.cgColor
        addSubview(colorView)
        
        colorView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        colorView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
    }
    
    func toggleBorder() {
        colorView.layer.borderWidth = isSelected ? 2 : 0
    }
    
    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
        super.init(coder: coder)
    }
}
