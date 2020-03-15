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
    fileprivate var cardView: UIView!
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
        backgroundColor = UIColor.clear
        layer.cornerRadius = 10
        layer.masksToBounds = true
        
        prepareCardView()
        
    }
    
    fileprivate func prepareCardView() {
        //the point of the card view is to incorporate the cell_spacing
        cardView = UIView()
        cardView.backgroundColor = UIColor.white
        cardView.layer.cornerRadius = 10
        cardView.layer.masksToBounds = true
        addSubview(cardView)
        
        _ = cardView.anchor(topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: GSRGroupConfirmBookingController.cellSpacing, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        
        prepareHeaderView()
        prepareTimeSlotsTableView()
    }
    
    fileprivate func prepareHeaderView() {
        headerView = UIView()
        cardView.addSubview(headerView)

        _ = headerView.anchor(cardView.topAnchor, left: cardView.leftAnchor, bottom: nil, right: cardView.rightAnchor, topConstant: 17.5, leftConstant: 15, bottomConstant: 0, rightConstant: 15.0, widthConstant: 0, heightConstant: 52.0)
        
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
        
        cardView.addSubview(timeSlotsTableView)
        
        _ = timeSlotsTableView.anchor(headerView.bottomAnchor, left: cardView.leftAnchor, bottom: cardView.bottomAnchor, right: cardView.rightAnchor, topConstant: 0, leftConstant: 15, bottomConstant: 0, rightConstant: 15, widthConstant: 0, heightConstant: 0)
    }
}

// MARK: - Cell Height
extension GroupBookingConfirmationCell {
    static func getCellHeight(for booking: GSRBooking) -> CGFloat {
        //height is header_height + header_top + #time_slots * time_slot_height + cell_spacing
        #warning("Should not be calculating split time ranges EVERY Time, and should not use a constant value. change!")
        let numTimeSlots = booking.getSplitTimeRanges(interval: 60 * 30).count
        return 52.0 + 17.5 + CGFloat(numTimeSlots) * GroupBookingTimeSlotCell.cellHeight + GSRGroupConfirmBookingController.cellSpacing
        
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
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView() //hide last separator line
    }
}
// MARK: - TimeSlotsTableView Delegate
extension GroupBookingConfirmationCell: UITableViewDelegate {
    
}
