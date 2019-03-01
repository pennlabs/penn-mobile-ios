//
//  NoReservationsCell.swift
//  PennMobile
//
//  Created by Marta García Ferreiro on 2/22/19.
//  Copyright © 2019 PennLabs. All rights reserved.
//

import Foundation

class NoReservationsCell: UITableViewCell {
    
    static let identifier = "noReservationsCell"
    static let cellHeight: CGFloat = 80
    
    fileprivate var label: UILabel!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.prepareLabel()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Prepare UI
extension NoReservationsCell {
    
    fileprivate func prepareLabel() {
        label = UILabel()
        label.text = "No current GSR reservations"
        label.font = .secondaryInformationFont
        label.textColor = .secondaryInformationGrey
        label.textAlignment = .center
        label.numberOfLines = 1
        
        addSubview(label)
        _ = label.anchor(topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0)
    }
}
