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
    static let cellHeight: CGFloat = 101
    
    var isHomepage: Bool = false {
        didSet {
            if isHomepage {
                adjustForHome()
            }
        }
    }
    
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
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
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
        locationLabel.font = UIFont(name: "AvenirNext-Regular", size: 16)
        locationLabel.textColor = .primaryTitleGrey
        locationLabel.textAlignment = .left
        locationLabel.numberOfLines = 1
        locationLabel.shrinkUntilFits()
        
        addSubview(locationLabel)
        _ = locationLabel.anchor(topAnchor, left: buildingImage.rightAnchor, bottom: nil, right: rightAnchor, topConstant: 9, leftConstant: 25, bottomConstant: 0, rightConstant: 10, widthConstant: 0, heightConstant: 0)
    }
    
    private func prepareDateLabel() {
        dateLabel = UILabel()
        dateLabel.font = UIFont(name: "AvenirNext-Regular", size: 14)
        dateLabel.textColor = .secondaryTitleGrey
        dateLabel.textAlignment = .left
        dateLabel.numberOfLines = 1
        dateLabel.shrinkUntilFits()
        
        addSubview(dateLabel)
        _ = dateLabel.anchor(locationLabel.bottomAnchor, left: buildingImage.rightAnchor, bottom: nil, right: nil, topConstant: 0, leftConstant: 25, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
    }
    
    private func prepareTimeLabel() {
        timeLabel = UILabel()
        timeLabel.font = UIFont(name: "AvenirNext-Regular", size: 14)
        timeLabel.textColor = .secondaryTitleGrey
        timeLabel.textAlignment = .left
        timeLabel.numberOfLines = 1
        timeLabel.shrinkUntilFits()
        
        addSubview(timeLabel)
        _ = timeLabel.anchor(dateLabel.bottomAnchor, left: buildingImage.rightAnchor, bottom: nil, right: nil, topConstant: 4, leftConstant: 25, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
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
        _ = deleteButton.anchor(timeLabel.bottomAnchor, left: buildingImage.rightAnchor, bottom: bottomAnchor, right: nil, topConstant: 6, leftConstant: 25, bottomConstant: 0, rightConstant: 0, widthConstant: 90, heightConstant: 24)    }
    
    @objc func handleDeletePressed(_ sender: Any) {
        self.delegate.deleteReservation(reservation)
    }
    
    func prepareBuildingImage() {
        buildingImage = UIImageView()
        buildingImage.translatesAutoresizingMaskIntoConstraints = false
        buildingImage.contentMode = .scaleAspectFill
        buildingImage.clipsToBounds = true
        buildingImage.layer.cornerRadius = 8.0
        addSubview(buildingImage)
        _ = buildingImage.anchor(topAnchor, left: leftAnchor, bottom: bottomAnchor, right: nil, topConstant: 14, leftConstant: 25, bottomConstant: 0, widthConstant: 139, heightConstant: 87)
    }
    
}

// MARK: - Homepage
extension ReservationCell {
    func adjustForHome() {
        buildingImage.widthAnchor.constraint(equalToConstant: 130).isActive = true
        buildingImage.layer.cornerRadius = 5.0
        buildingImage.leftAnchor.constraint(equalTo: leftAnchor, constant: 14).isActive = true
        locationLabel.leftAnchor.constraint(equalTo: buildingImage.rightAnchor, constant: 14).isActive = true
        dateLabel.leftAnchor.constraint(equalTo: buildingImage.rightAnchor, constant: 14).isActive = true
        timeLabel.leftAnchor.constraint(equalTo: buildingImage.rightAnchor, constant: 14).isActive = true
        deleteButton.leftAnchor.constraint(equalTo: buildingImage.rightAnchor, constant: 14).isActive = true
        
    }
}
