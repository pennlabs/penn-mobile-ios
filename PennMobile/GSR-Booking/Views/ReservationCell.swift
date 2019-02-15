//
//  ReservationCell.swift
//  PennMobile
//
//  Created by Josh Doman on 2/15/19.
//  Copyright © 2019 PennLabs. All rights reserved.
//

import Foundation
import UIKit

protocol ReservationCellDelegate {
    func deleteReservaton(_ reservation: GSRReservation)
}

class ReservationCell: UITableViewCell {
    
    static let identifer = "reservationCell"
    static let cellHeight: CGFloat = 100
    
    var reservation: GSRReservation! {
        didSet {
            locationLabel.text = reservation.location
            dateLabel.text = reservation.date
            timeLabel.text = "\(reservation.startTime) - \(reservation.endTime)"
        }
    }
    
    var delegate: ReservationCellDelegate!
    
    fileprivate var locationLabel: UILabel!
    fileprivate var dateLabel: UILabel!
    fileprivate var timeLabel: UILabel!
    fileprivate var deleteButton: UIButton!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.prepareUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Prepare UI
extension ReservationCell {
    fileprivate func prepareUI() {
        prepareLocationLabel()
        prepareDateLabel()
        prepareTimeLabel()
        prepareDeleteButton()
    }
    
    private func prepareLocationLabel() {
        locationLabel = UILabel()
        
        addSubview(locationLabel)
        _ = locationLabel.anchor(topAnchor, left: leftAnchor, bottom: nil, right: nil, topConstant: 8, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
    }
    
    private func prepareDateLabel() {
        dateLabel = UILabel()
        
        addSubview(dateLabel)
        _ = dateLabel.anchor(locationLabel.bottomAnchor, left: leftAnchor, bottom: nil, right: nil, topConstant: 8, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
    }
    
    private func prepareTimeLabel() {
        timeLabel = UILabel()
        
        addSubview(timeLabel)
        _ = timeLabel.anchor(dateLabel.bottomAnchor, left: leftAnchor, bottom: nil, right: nil, topConstant: 8, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
    }
    
    private func prepareDeleteButton() {
        deleteButton = UIButton(type: .system)
        deleteButton.setTitle("Delete", for: .normal)
        deleteButton.addTarget(self, action: #selector(handleDeletePressed(_:)), for: .touchUpInside)
        
        addSubview(deleteButton)
        _ = deleteButton.anchor(nil, left: nil, bottom: nil, right: rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 4, widthConstant: 0, heightConstant: 0)
        deleteButton.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }
    
    func handleDeletePressed(_ sender: Any) {
        self.delegate.deleteReservaton(reservation)
    }
}
