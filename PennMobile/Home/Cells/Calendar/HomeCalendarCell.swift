//
//  HomeCalendarCell.swift
//  PennMobile
//
//  Created by Marta García Ferreiro on 11/6/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//

import UIKit

final class HomeCalendarCell: UITableViewCell, HomeCellConformable {
    static var identifier: String = "calendarCell"
    static func getCellHeight(for item: ModularTableViewItem) -> CGFloat {
        return 100.0 + HomeViewController.cellSpacing
    }
    
    var item: ModularTableViewItem! {
        didSet {
            guard let item = item as? HomeCalendarCellItem else { return }
            setupCell(with: item)
        }
    }
    
    var delegate: ModularTableViewCellDelegate!
    
    var cardView: UIView! = UIView()
    
    var titleLabel: UILabel!
    var myLabel: UILabel!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        prepareHomeCell()
        prepareUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Prepare UI
extension HomeCalendarCell {
    fileprivate func prepareUI() {
        prepareTitleLabel()
        prepareMyLabel()
    }
    
    private func prepareTitleLabel() {
        titleLabel = UILabel()
        titleLabel.text = "Upcoming Events"
        titleLabel.font = .primaryTitleFont
        titleLabel.textColor = .primaryTitleGrey
        titleLabel.textAlignment = .left
        
        cardView.addSubview(titleLabel)
        _ = titleLabel.anchor(cardView.topAnchor, left: cardView.leftAnchor, bottom: nil, right: nil, topConstant: 12, leftConstant: 20, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
    }
    
    private func prepareMyLabel() {
        myLabel = UILabel()
        
        cardView.addSubview(myLabel)
        _ = myLabel.anchor(nil, left: cardView.leftAnchor, bottom: cardView.bottomAnchor, right: nil, topConstant: 0, leftConstant: 20, bottomConstant: 10, rightConstant: 0, widthConstant: 0, heightConstant: 0)   }
}


