//
//  ReservationCell.swift
//  PennMobile
//
//  Created by Josh Doman on 2/15/19.
//  Copyright © 2019 PennLabs. All rights reserved.
//

import UIKit

protocol ReservationCellDelegate {
    func deleteReservation(_ reservation: GSRReservation)
}

class ReservationCell: UITableViewCell {
    
    static let identifier = "reservationCell"
    static let cellHeight: CGFloat = 98
    
    var isHomePageCell: Bool = false {
        didSet {
            if isHomePageCell {
                if buildingImageLeftConstraint != nil {
                    buildingImage.removeConstraint(buildingImageLeftConstraint)
                    buildingImageLeftConstraint = buildingImage.leftAnchor.constraint(equalTo: leftAnchor)
                    buildingImageLeftConstraint.isActive = true
                }
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
            
            if let url = URL(string: "https://s3.us-east-2.amazonaws.com/labs.api/gsr/lid-\(reservation.lid)-gid-\(reservation.gid).jpg") {
                buildingImage.kf.setImage(with: url)
            }
        }
    }
    
    var delegate: ReservationCellDelegate!
    
    fileprivate var locationLabel: UILabel!
    fileprivate var dateLabel: UILabel!
    fileprivate var timeLabel: UILabel!
    fileprivate var deleteButton: UIButton!
    fileprivate var buildingImage: UIImageView!
    
    fileprivate var buildingImageLeftConstraint: NSLayoutConstraint!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.prepareUI()
        self.accessoryType = .disclosureIndicator
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Prepare UI
extension ReservationCell {
    fileprivate func prepareUI() {
        backgroundColor = .clear
        prepareBuildingImage()
        prepareLocationLabel()
        prepareDateLabel()
        prepareTimeLabel()
    }
    
    private func prepareLocationLabel() {
        locationLabel = UILabel()
        locationLabel.font = .systemFont(ofSize: 17, weight: .medium)
        locationLabel.textColor = .labelPrimary
        locationLabel.textAlignment = .left
        locationLabel.numberOfLines = 1
        
        addSubview(locationLabel)
        
        locationLabel.translatesAutoresizingMaskIntoConstraints = false
        locationLabel.centerYAnchor.constraint(equalTo: buildingImage.centerYAnchor).isActive = true
        locationLabel.leftAnchor.constraint(equalTo: buildingImage.rightAnchor, constant: 14).isActive = true
        locationLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: 10).isActive = true
    }
    
    private func prepareDateLabel() {
        dateLabel = UILabel()
        dateLabel.font = .systemFont(ofSize: 14)
        dateLabel.textColor = .labelSecondary
        dateLabel.textAlignment = .left
        dateLabel.numberOfLines = 1
        dateLabel.shrinkUntilFits()
        
        addSubview(dateLabel)
        _ = dateLabel.anchor(nil, left: buildingImage.rightAnchor,
                             bottom: locationLabel.topAnchor, right: nil,
                             leftConstant: 14,
                             bottomConstant: 4)
    }
    
    private func prepareTimeLabel() {
        timeLabel = UILabel()
        timeLabel.font = .systemFont(ofSize: 14)
        timeLabel.textColor = .labelSecondary
        timeLabel.textAlignment = .left
        timeLabel.numberOfLines = 1
        timeLabel.shrinkUntilFits()
        
        addSubview(timeLabel)
        _ = timeLabel.anchor(locationLabel.bottomAnchor, left: buildingImage.rightAnchor,
                             bottom: nil, right: nil,
                             topConstant: 4, leftConstant: 14)
    }

    @objc func handleDeletePressed(_ sender: Any) {
        self.delegate.deleteReservation(reservation)
    }
    
    func prepareBuildingImage() {
        buildingImage = UIImageView()
        buildingImage.translatesAutoresizingMaskIntoConstraints = false
        buildingImage.contentMode = .scaleAspectFill
        buildingImage.clipsToBounds = true
        buildingImage.layer.cornerRadius = 7.0
        addSubview(buildingImage)
        buildingImageLeftConstraint = buildingImage.anchor(topAnchor, left: leftAnchor,
                                                           bottom: bottomAnchor, right: nil,
                                                           topConstant: 12, leftConstant: 14,
                                                           bottomConstant: 12, widthConstant: 116,
                                                           heightConstant: 74)[1]
    }
    
}
