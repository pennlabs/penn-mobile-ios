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

            //colorView.layer.borderColor = borderColor.cgColor
        }
    }

    var borderColor: UIColor! /*{
        didSet {
            colorView.layer.borderColor = borderColor.cgColor;
        }
        
    }*/

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    private func setupView() {
        colorView = UIView()
        colorView.translatesAutoresizingMaskIntoConstraints = false
        colorView.heightAnchor.constraint(equalToConstant: 30).isActive = true
        colorView.widthAnchor.constraint(equalToConstant: 30).isActive = true
        colorView.layer.cornerRadius = 15
        colorView.layer.masksToBounds = false
        colorView.layer.borderWidth = 0
        /*
        if ((color) != nil) {
            let components = color.cgColor.components
            
            borderColor = UIColor(red: components![0], green: components![1], blue: components![2], alpha:0.8)
        } else {
            borderColor = UIColor(red: 32, green: 156, blue: 238, alpha:0.8)
        }
        */
        //borderColor = colorView.backgroundColor?.withAlphaComponent(0.8)

//        colorView.layer.borderColor = borderColor.cgColor
        addSubview(colorView)

        colorView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        colorView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
    }

    func toggleBorder() {
        if isSelected {
            colorView.layer.borderColor = borderColor.cgColor
        }

        colorView.layer.borderWidth = isSelected ? 4 : 0
    }

    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
        super.init(coder: coder)
    }
}
