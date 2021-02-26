//
//  CourseAlertCreateCell.swift
//  PennMobile
//
//  Created by Raunaq Singh on 11/8/20.
//  Copyright © 2020 PennLabs. All rights reserved.
//
import Foundation

class CourseAlertCreateCell: UITableViewCell {
    
    static let cellHeight: CGFloat = 60
    static let identifier = "createAlertCell"
    
    fileprivate var titleLabel: UILabel!
    fileprivate var alertSymbol: UIImageView!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        prepareUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Prepare UI
extension CourseAlertCreateCell {
    
    fileprivate func prepareUI() {
        prepareTitleLabel()
        prepareAlertSymbol()
    }
    
    fileprivate func prepareTitleLabel() {
        titleLabel = UILabel()
        titleLabel.text = "Create Alert"
        titleLabel.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        titleLabel.textColor = UIColor(named: "baseLabsBlue")
        addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor, constant: -12).isActive = true
    }
    
    fileprivate func prepareAlertSymbol() {
        alertSymbol = UIImageView(frame: CGRect(x: 0, y: 0, width: 16, height: 16))
        if #available(iOS 13.0, *) {
            alertSymbol.image = UIImage(systemName: "bell.fill")
        } else {
            alertSymbol.image = UIImage(named: "bell")
        }
        alertSymbol.tintColor = .baseLabsBlue
        
        addSubview(alertSymbol)
        alertSymbol.translatesAutoresizingMaskIntoConstraints = false
        alertSymbol.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        alertSymbol.centerXAnchor.constraint(equalTo: centerXAnchor, constant: titleLabel.intrinsicContentSize.width/2 + 2).isActive = true
    }
    
}
