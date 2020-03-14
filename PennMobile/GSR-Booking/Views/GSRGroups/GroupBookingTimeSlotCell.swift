//
//  GroupBookingTimeSlotCell.swift
//  PennMobile
//
//  Created by Rehaan Furniturewala on 3/14/20.
//  Copyright © 2020 PennLabs. All rights reserved.
//

import UIKit

class GroupBookingTimeSlotCell: UITableViewCell {

    //pennkey, timestart, timeend, bookedSuccessfully
    fileprivate var timeSlotLabel: UILabel!
    fileprivate var pennkeyLabel: UILabel!
    fileprivate var bookingStatusIcon: UIImageView!
    fileprivate var pennkey: String! {
        didSet {
            pennkeyLabel.text = pennkey
        }
    }
    fileprivate var bookingStatus: Bool! {
        didSet {
//            bookingStatusIcon.image =
        }
    }
        
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        prepareUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func setupCell(start: Date, end: Date) {
        
    }
    
}

// MARK: - Prepare UI
extension GroupBookingTimeSlotCell {
    fileprivate func prepareUI() {
        
    }
}
