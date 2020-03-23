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
    static let cellHeight: CGFloat = 110
    
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
                buildingImageView.kf.setImage(with: url)
            }
        }
    }
    
    var delegate: ReservationCellDelegate!
    
    @objc func handleDeletePressed(_ sender: Any) {
        self.delegate.deleteReservation(reservation)
    }
    
    // MARK: - UI Elements
    fileprivate var safeArea: UIView!
    fileprivate var locationLabel: UILabel!
    fileprivate var dateLabel: UILabel!
    fileprivate var timeLabel: UILabel!
    fileprivate var deleteButton: UIButton!
    fileprivate var buildingImageView: UIImageView!
    
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
        backgroundColor = .clear
        accessoryType = .none
        prepareSafeArea()
        prepareImageView()
        prepareLabelsAndButton()
    }
    
    // MARK: Safe Area
    fileprivate func prepareSafeArea() {
        safeArea = UIView()
        addSubview(safeArea)
        
        safeArea.snp.makeConstraints { (make) in
            make.leading.equalTo(self).offset(pad)
            make.trailing.equalTo(self).offset(-pad * 2)
            make.top.equalTo(self).offset(pad)
            make.bottom.equalTo(self).offset(-pad)
        }
    }
    
    // MARK: ImageView
    fileprivate func prepareImageView() {
        buildingImageView = getBuildingImageView()
        addSubview(buildingImageView)
        
        buildingImageView.snp.makeConstraints { (make) in
            make.width.equalTo(134)
            make.height.equalTo(86)
            make.leading.equalTo(safeArea)
            make.centerY.equalTo(safeArea)
        }
    }
    
    // MARK: Labels
    fileprivate func prepareLabelsAndButton() {
        locationLabel = getLocationLabel()
        addSubview(locationLabel)
        timeLabel = getTimeOrDateLabel()
        addSubview(timeLabel)
        dateLabel = getTimeOrDateLabel()
        addSubview(dateLabel)
        deleteButton = getDeleteButton()
        addSubview(deleteButton)
        
        locationLabel.snp.makeConstraints { (make) in
            make.top.equalTo(buildingImageView.snp.top).offset(-2)
            make.leading.equalTo(buildingImageView.snp.trailing).offset(pad)
            make.trailing.equalTo(safeArea)
        }
        
        dateLabel.snp.makeConstraints { (make) in
            make.leading.equalTo(locationLabel.snp.leading)
            make.top.equalTo(locationLabel.snp.bottom).offset(3)
            make.trailing.equalTo(safeArea)
        }
        
        timeLabel.snp.makeConstraints { (make) in
            make.leading.equalTo(locationLabel.snp.leading)
            make.top.equalTo(dateLabel.snp.bottom).offset(3)
            make.trailing.equalTo(safeArea)
        }
        
        deleteButton.snp.makeConstraints { (make) in
            make.width.equalTo(94)
            make.height.equalTo(24)
            make.leading.equalTo(locationLabel.snp.leading)
            make.bottom.equalTo(buildingImageView.snp.bottom)
        }
    }
    
    fileprivate func getBuildingImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.backgroundColor = .grey2
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 5.0
        return imageView
    }
    
    fileprivate func getLocationLabel() -> UILabel {
        let label = UILabel()
        label.font = .interiorTitleFont
        label.textColor = .labelPrimary
        label.textAlignment = .left
        label.shrinkUntilFits()
        return label
    }
    
    fileprivate func getTimeOrDateLabel() -> UILabel {
        let label = UILabel()
        label.font = .secondaryInformationFont
        label.textColor = .labelSecondary
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        label.shrinkUntilFits()
        return label
    }
    
    private func getDeleteButton() -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle("Delete", for: .normal)
        button.addTarget(self, action: #selector(handleDeletePressed(_:)), for: .touchUpInside)
        button.backgroundColor = .baseRed
        button.layer.cornerRadius = 4
        button.titleLabel?.font = .secondaryTitleFont
        button.titleLabel?.textColor = .white
        button.tintColor = .white
        button.titleLabel?.textAlignment = .center
        return button
    }
}
