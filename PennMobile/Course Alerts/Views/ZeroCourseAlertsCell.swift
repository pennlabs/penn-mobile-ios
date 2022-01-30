//
//  CourseAlertCreateCell.swift
//  PennMobile
//
//  Created by Raunaq Singh on 11/8/20.
//  Copyright © 2020 PennLabs. All rights reserved.
//
import Foundation

class ZeroCourseAlertsCell: UITableViewCell {
    
    static let cellHeight: CGFloat = 250
    static let identifier = "zeroCourseAlertsCell"
    
    fileprivate var titleLabel: UILabel!
    fileprivate var alertSymbol: UIImageView!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        let noAlertsLabel = UILabel()
        noAlertsLabel.text = "No Current Penn Course Alerts."
        noAlertsLabel.font = UIFont.avenirMedium
        noAlertsLabel.textColor = .lightGray
        
        addSubview(noAlertsLabel)
        
        noAlertsLabel.translatesAutoresizingMaskIntoConstraints = false
        noAlertsLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        noAlertsLabel.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -50).isActive = true
        
        
        titleLabel = UILabel()
        titleLabel.text = "Create Alert"
        titleLabel.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        titleLabel.textColor = UIColor.baseLabsBlue
        addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor, constant: -12).isActive = true
        
        alertSymbol = UIImageView(frame: CGRect(x: 0, y: 0, width: 16, height: 16))
        alertSymbol.image = UIImage(systemName: "bell.fill")
        alertSymbol.tintColor = .baseLabsBlue
        
        addSubview(alertSymbol)
        alertSymbol.translatesAutoresizingMaskIntoConstraints = false
        alertSymbol.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        alertSymbol.centerXAnchor.constraint(equalTo: centerXAnchor, constant: titleLabel.intrinsicContentSize.width/2 + 2).isActive = true

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
