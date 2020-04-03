//
//  GroupBookingTimeSlotCell.swift
//  PennMobile
//
//  Created by Rehaan Furniturewala on 3/14/20.
//  Copyright © 2020 PennLabs. All rights reserved.
//

import UIKit

class GroupBookingTimeSlotCell: UITableViewCell {

    static let identifier = "gsrGroupBookingTimeSlotCell"
    static let cellHeight: CGFloat = 52.0
    
    fileprivate var timeSlotLabel: UILabel!
    fileprivate var pennkeyLabel: UILabel!
    fileprivate var bookingStatusIcon: UIImageView!
    
    var timeSlot: GSRGroupBookingSlot! {
        didSet {
            timeSlotLabel.text = timeSlot.strRange()
            if let pennkey = timeSlot.pennkey {
                pennkeyLabel.text = pennkey
            }
            if let booked = timeSlot.booked {
                bookingStatusIcon.backgroundColor = booked ? UIColor.baseGreen : UIColor.baseRed
            }
        }
    }
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        prepareUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

// MARK: - Prepare UI
extension GroupBookingTimeSlotCell {
    fileprivate func prepareUI() {
        prepareBookingStatusIcon()
        prepareTimeSlotLabel()
        preparePennkeyLabel()
    }
    
    fileprivate func prepareBookingStatusIcon() {
        bookingStatusIcon = UIImageView()
        bookingStatusIcon.layer.cornerRadius = 10
        bookingStatusIcon.layer.masksToBounds = true
        bookingStatusIcon.layer.borderWidth = 1.5
        bookingStatusIcon.layer.borderColor = UIColor.grey3.cgColor
        addSubview(bookingStatusIcon)
        
        _ = bookingStatusIcon.anchor(nil, left: nil, bottom: nil, right: rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 12, widthConstant: 20, heightConstant: 20)
        bookingStatusIcon.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }
    
    fileprivate func prepareTimeSlotLabel() {
        timeSlotLabel = UILabel()
        timeSlotLabel.font = UIFont.gsrCellTextFont
        addSubview(timeSlotLabel)
        
        _ = timeSlotLabel.anchor(nil, left: leftAnchor, bottom: nil, right: bookingStatusIcon.leftAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 20)
        timeSlotLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }
    
    fileprivate func preparePennkeyLabel() {
        pennkeyLabel = UILabel()
        pennkeyLabel.font = UIFont.gsrCellSubtextFont
        addSubview(pennkeyLabel)
        
        _ = pennkeyLabel.anchor(timeSlotLabel.bottomAnchor, left: timeSlotLabel.leftAnchor, bottom: bottomAnchor, right: timeSlotLabel.rightAnchor, topConstant: 0, leftConstant: 2, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
    }
}
