//
//  CourseAlertCell.swift
//  PennMobile
//
//  Created by Raunaq Singh on 10/25/20.
//  Copyright © 2020 PennLabs. All rights reserved.
//

import Foundation
import UIKit

class CourseAlertCell: UITableViewCell {

    static let cellHeight: CGFloat = 100
    static let identifier = "courseAlertCell"
    
    fileprivate var detailLabel: UILabel!
    fileprivate var courseLabel: UILabel!
    fileprivate var activeLabel: UILabel!
    fileprivate var courseStatusLabel: UILabel!
    fileprivate var activeDot: UIView!
    fileprivate var statusDot: UIView!
    fileprivate var moreView: UIImageView!
    
    var courseAlert: CourseAlert! {
        didSet {
            setupCell()
        }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


// MARK: - Setup Cell
extension CourseAlertCell {
    fileprivate func setupCell() {
        
        if (detailLabel == nil || courseLabel == nil || courseStatusLabel == nil || activeLabel == nil || activeDot == nil || statusDot == nil || moreView == nil) {
            setupUI()
        } else {
            detailLabel.text = "One-Time Alert"
            if let notifDate = courseAlert.notificationSentAt {
                //let alertNotifDate = Date.dayOfMonthFormatter.string(from: notifDate)
                let alertNotifDate = notifDate
                detailLabel.text = "One-Time Alert - Last Notified \(alertNotifDate)"
            }
            courseLabel.text = courseAlert.section
            
            activeDot.backgroundColor = courseAlert.isActive ? UIColor.baseGreen : UIColor.grey1
            activeLabel.text = courseAlert.isActive ? "ACTIVE" : "INACTIVE"
            activeLabel.textColor = courseAlert.isActive ? UIColor.baseGreen : UIColor.grey1
       
            statusDot.backgroundColor = courseAlert.sectionStatus == "O" ? UIColor.blueLight : UIColor.grey1
            statusDot.isHidden = !courseAlert.isActive
            courseStatusLabel.text = courseAlert.sectionStatus == "O" ? "COURSE OPEN" : "COURSE CLOSED"
            courseStatusLabel.textColor = courseAlert.sectionStatus == "O" ? UIColor.blueLight : UIColor.grey1
            courseStatusLabel.isHidden = !courseAlert.isActive
            
        }
    }
}


// MARK: - Setup UI
extension CourseAlertCell {
    fileprivate func setupUI() {
        prepareCourseLabel()
        prepareActiveDot()
        prepareActiveLabel()
        prepareStatusDot()
        prepareCourseStatusLabel()
        prepareDetailLabel()
        prepareMoreView()
    }
    
    fileprivate func prepareCourseLabel() {
        courseLabel = UILabel()
        courseLabel.font = UIFont.primaryTitleFont
        addSubview(courseLabel)
        courseLabel.translatesAutoresizingMaskIntoConstraints = false
        courseLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15).isActive = true
        courseLabel.topAnchor.constraint(equalTo: centerYAnchor, constant: -10).isActive = true
    }
    
    fileprivate func prepareActiveDot() {
        activeDot = UIView()
        activeDot.layer.cornerRadius = 4
        addSubview(activeDot)
        activeDot.translatesAutoresizingMaskIntoConstraints = false
        activeDot.widthAnchor.constraint(equalToConstant: 8).isActive = true
        activeDot.heightAnchor.constraint(equalToConstant: 8).isActive = true
        activeDot.leadingAnchor.constraint(equalTo: courseLabel.leadingAnchor).isActive = true
        activeDot.topAnchor.constraint(equalTo: courseLabel.topAnchor, constant: -20).isActive = true
    }
    
    fileprivate func prepareActiveLabel() {
        activeLabel = UILabel()
        activeLabel.font = UIFont.primaryInformationFont
        addSubview(activeLabel)
        activeLabel.translatesAutoresizingMaskIntoConstraints = false
        activeLabel.leadingAnchor.constraint(equalTo: activeDot.trailingAnchor, constant: 3).isActive = true
        activeLabel.centerYAnchor.constraint(equalTo: activeDot.centerYAnchor, constant: 0).isActive = true
    }
    
    fileprivate func prepareStatusDot() {
        statusDot = UIView()
        statusDot.layer.cornerRadius = 4
        addSubview(statusDot)
        statusDot.translatesAutoresizingMaskIntoConstraints = false
        statusDot.widthAnchor.constraint(equalToConstant: 8).isActive = true
        statusDot.heightAnchor.constraint(equalToConstant: 8).isActive = true
        statusDot.leadingAnchor.constraint(equalTo: activeLabel.trailingAnchor, constant: 8).isActive = true
        statusDot.topAnchor.constraint(equalTo: courseLabel.topAnchor, constant: -20).isActive = true
    }
    
    fileprivate func prepareCourseStatusLabel() {
        courseStatusLabel = UILabel()
        courseStatusLabel.font = UIFont.primaryInformationFont
        addSubview(courseStatusLabel)
        courseStatusLabel.translatesAutoresizingMaskIntoConstraints = false
        courseStatusLabel.leadingAnchor.constraint(equalTo: statusDot.trailingAnchor, constant: 3).isActive = true
        courseStatusLabel.centerYAnchor.constraint(equalTo: statusDot.centerYAnchor, constant: 0).isActive = true
    }
    
    fileprivate func prepareDetailLabel() {
        detailLabel = UILabel()
        detailLabel.font = UIFont.secondaryInformationFont
        detailLabel.textColor = UIColor.grey1
        addSubview(detailLabel)
        detailLabel.translatesAutoresizingMaskIntoConstraints = false
        detailLabel.leadingAnchor.constraint(equalTo: courseLabel.leadingAnchor).isActive = true
        detailLabel.topAnchor.constraint(equalTo: courseLabel.bottomAnchor, constant: 6).isActive = true
    }
    
    fileprivate func prepareMoreView() {
        moreView = UIImageView(image: UIImage(named: "More_Grey"))
        moreView.contentMode = .scaleAspectFit
        addSubview(moreView)
        moreView.translatesAutoresizingMaskIntoConstraints = false
        moreView.widthAnchor.constraint(equalToConstant: 20).isActive = true
        moreView.heightAnchor.constraint(equalToConstant: 20).isActive = true
        moreView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20).isActive = true
        moreView.centerYAnchor.constraint(equalTo: courseLabel.centerYAnchor).isActive = true
    }
    
}
