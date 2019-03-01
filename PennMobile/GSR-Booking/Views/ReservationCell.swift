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
    func deleteReservation(_ reservation: GSRReservation)
}

class ReservationCell: UITableViewCell {
    
    static let identifier = "reservationCell"
    static let cellHeight: CGFloat = 127
    
    var reservation: GSRReservation! {
        didSet {
            locationLabel.text = String(reservation.roomName.split(separator: ":").first ?? "")
            
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM d, YYYY"
            dateLabel.text = formatter.string(from: reservation.startDate)
            
            formatter.dateFormat = "h:mm a"
            let startStr = formatter.string(from: reservation.startDate)
            let endStr = formatter.string(from: reservation.endDate)
            timeLabel.text = "\(startStr) - \(endStr)"
            
            if (reservation.lid == 1086 && reservation.gid != 1889){
                let imageName = "lid-\(reservation.lid)"
                buildingImage.image = UIImage(named: imageName)
            }
            else {
                let imageName = "lid-\(reservation.lid)-gid-\(reservation.gid)"
                buildingImage.image = UIImage(named: imageName)
            }
        }
    }
    
    var delegate: ReservationCellDelegate!
    
    fileprivate var locationLabel: UILabel!
    fileprivate var dateLabel: UILabel!
    fileprivate var timeLabel: UILabel!
    fileprivate var deleteButton: UIButton!
    fileprivate var buildingImage: UIImageView!
    
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
        prepareBuildingImage()
        prepareLocationLabel()
        prepareDateLabel()
        prepareTimeLabel()
        prepareDeleteButton()
    }
    
    private func prepareLocationLabel() {
        locationLabel = UILabel()
        locationLabel.font = UIFont(name: "AvenirNext-DemiBold", size: 16)
        locationLabel.textColor = .primaryTitleGrey
        locationLabel.textAlignment = .left
        locationLabel.numberOfLines = 1
        
        addSubview(locationLabel)
        _ = locationLabel.anchor(topAnchor, left: buildingImage.rightAnchor, bottom: nil, right: rightAnchor, topConstant: 14, leftConstant: 25, bottomConstant: 0, rightConstant: 10, widthConstant: 0, heightConstant: 0)
    }
    
    private func prepareDateLabel() {
        dateLabel = UILabel()
        dateLabel.font = UIFont(name: "AvenirNext-Regular", size: 14)
        dateLabel.textColor = .secondaryTitleGrey
        dateLabel.textAlignment = .left
        dateLabel.numberOfLines = 1
        dateLabel.shrinkUntilFits()
        
        addSubview(dateLabel)
        _ = dateLabel.anchor(locationLabel.bottomAnchor, left: buildingImage.rightAnchor, bottom: nil, right: nil, topConstant: 3, leftConstant: 25, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
    }
    
    private func prepareTimeLabel() {
        timeLabel = UILabel()
        timeLabel.font = UIFont(name: "AvenirNext-Regular", size: 14)
        timeLabel.textColor = .secondaryTitleGrey
        timeLabel.textAlignment = .left
        timeLabel.numberOfLines = 1
        timeLabel.shrinkUntilFits()
        
        addSubview(timeLabel)
        _ = timeLabel.anchor(dateLabel.bottomAnchor, left: buildingImage.rightAnchor, bottom: nil, right: nil, topConstant: 3, leftConstant: 25, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
    }
    
    private func prepareDeleteButton() {
        deleteButton = UIButton(type: .system)
        deleteButton.setTitle("Delete", for: .normal)
        deleteButton.addTarget(self, action: #selector(handleDeletePressed(_:)), for: .touchUpInside)
        deleteButton.backgroundColor = .redingTerminal
        deleteButton.layer.cornerRadius = 4
        deleteButton.titleLabel?.font = UIFont(name: "AvenirNext-Regular", size: 12)
        deleteButton.titleLabel?.textColor = .white
        deleteButton.tintColor = .white
        deleteButton.titleLabel?.textAlignment = .center
        
        addSubview(deleteButton)
        _ = deleteButton.anchor(timeLabel.bottomAnchor, left: buildingImage.rightAnchor, bottom: bottomAnchor, right: nil, topConstant: 5, leftConstant: 25, bottomConstant: 14, rightConstant: 0, widthConstant: 90, heightConstant: 24)    }
    
    func handleDeletePressed(_ sender: Any) {
        self.delegate.deleteReservation(reservation)
    }
    
    func prepareBuildingImage() {
        buildingImage = UIImageView()
        buildingImage.translatesAutoresizingMaskIntoConstraints = false
        buildingImage.contentMode = .scaleAspectFill
        buildingImage.clipsToBounds = true
        buildingImage.layer.cornerRadius = 8.0
        addSubview(buildingImage)
        _ = buildingImage.anchor(topAnchor, left: leftAnchor, bottom: bottomAnchor, right: nil, topConstant: 20, leftConstant: 25, bottomConstant: 20, widthConstant: 139, heightConstant: 87)
    }
    
}
