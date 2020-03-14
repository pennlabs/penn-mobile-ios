//
//  GroupBookingConfirmationCell.swift
//  PennMobile
//
//  Created by Rehaan Furniturewala on 3/13/20.
//  Copyright © 2020 PennLabs. All rights reserved.
//

import UIKit

class GroupBookingConfirmationCell: UITableViewCell {

    static let identifier = "gsrGroupBookingConfirmationCell"
    
    fileprivate var headerView: UIView!
    fileprivate var locationLabel: UILabel!
    fileprivate var dateLabel: UILabel!
    fileprivate var buildingImageView: UIImageView!
    fileprivate var timeSlotsTableView: UITableView!
    
    fileprivate var timeSlots: [String]!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        prepareUI()
    }
    
    func setupCell(with booking: GSRBooking) {
        locationLabel.text = "\(booking.location.name)"
        dateLabel.text = booking.start.dayOfWeek
        if let url = URL(string: "https://s3.us-east-2.amazonaws.com/labs.api/gsr/lid-\(booking.location.lid)-gid-\(booking.location.gid ?? booking.location.lid).jpg") {
            buildingImageView.kf.setImage(with: url)
        }
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .none
        
        //convert ranges to times
        let timeRanges = booking.getSplitTimeRanges(interval: TimeInterval(60 * 30))
        timeSlots = timeRanges.map({
            return "\(formatter.string(from: $0.lowerBound)) - \(formatter.string(from: $0.upperBound))"
        })
    }
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

// MARK: - Prepare UI
extension GroupBookingConfirmationCell {
    fileprivate func prepareUI() {
        backgroundColor = UIColor.white
        layer.cornerRadius = 10
        layer.masksToBounds = true
        
        prepareHeaderView()
        prepareTimeSlotsTableView()
    }
    
    fileprivate func prepareHeaderView() {
        headerView = UIView()
        addSubview(headerView)

        _ = headerView.anchor(topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, topConstant: 17.5, leftConstant: 15, bottomConstant: 17.5, rightConstant: 15.0, widthConstant: 0, heightConstant: 52.0)
        
        prepareBuildingImageView()
        prepareLocationLabel()
        prepareDateLabel()
    }
    
    fileprivate func prepareBuildingImageView() {
        buildingImageView = UIImageView()
        buildingImageView.clipsToBounds = true
        buildingImageView.layer.cornerRadius = 9
        buildingImageView.layer.masksToBounds = true
        headerView.addSubview(buildingImageView)
        
        _ = buildingImageView.anchor(headerView.topAnchor, left: headerView.leftAnchor, bottom: headerView.bottomAnchor, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 73.0, heightConstant: 0)
    }
    
    fileprivate func prepareLocationLabel() {
        locationLabel = UILabel()
        locationLabel.font = UIFont.gsrCellTitleFont
        headerView.addSubview(locationLabel)
        
        _ = locationLabel.anchor(headerView.topAnchor, left: buildingImageView.rightAnchor, bottom: nil, right: headerView.rightAnchor, topConstant: 0, leftConstant: 15.0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        locationLabel.heightAnchor.constraint(equalTo: headerView.heightAnchor, multiplier: 0.5, constant: 0).isActive = true
    }

    fileprivate func prepareDateLabel() {
        dateLabel = UILabel()
        dateLabel.font = UIFont.gsrCellSubtitleFont
        headerView.addSubview(dateLabel)
        
        _ = dateLabel.anchor(locationLabel.bottomAnchor, left: locationLabel.leftAnchor, bottom: headerView.bottomAnchor, right: headerView.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
    }
    
    fileprivate func prepareTimeSlotsTableView() {
        timeSlotsTableView = UITableView()
        timeSlotsTableView.dataSource = self
        timeSlotsTableView.delegate = self
        timeSlotsTableView.allowsSelection = false
        timeSlotsTableView.isScrollEnabled = false
        timeSlotsTableView.register(GroupBookingTimeSlotCell.self, forCellReuseIdentifier: GroupBookingTimeSlotCell.identifier)
        
        addSubview(timeSlotsTableView)
        
        #warning("don't set a fixed height in the future, but i'm doing it for now, cos otherwise tableview doesn't show")
        _ = timeSlotsTableView.anchor(headerView.bottomAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, topConstant: 0, leftConstant: 15, bottomConstant: 0, rightConstant: 15, widthConstant: 0, heightConstant: 300)
    }
}

// MARK: - TimeSlotsTableView DataSource
extension GroupBookingConfirmationCell: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return GroupBookingTimeSlotCell.cellHeight
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return timeSlots.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: GroupBookingTimeSlotCell.identifier) as! GroupBookingTimeSlotCell
        cell.timeSlot = timeSlots[indexPath.row]
        return cell
    }
    
    
}
// MARK: - TimeSlotsTableView Delegate
extension GroupBookingConfirmationCell: UITableViewDelegate {
    
}
