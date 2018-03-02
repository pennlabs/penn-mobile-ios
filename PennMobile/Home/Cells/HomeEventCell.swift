//
//  HomeEventCell.swift
//  PennMobile
//
//  Created by Josh Doman on 1/17/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//

import Foundation
import UIKit

final class HomeEventCell: UITableViewCell, HomeCellConformable {
    static var identifier = "eventCell"
    static var cellHeight: CGFloat = 100.0
    
    var delegate: HomeCellDelegate!
    var item: HomeViewModelItem? {
        didSet {
            guard let item = item as? HomeViewModelEventItem else { return }
            setupCell(with: item)
        }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        prepareHomeCell()
        prepareTextLabel()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Setup and Prepare UI Elements
extension HomeEventCell {
    fileprivate func prepareTextLabel() {
        textLabel?.textColor = UIColor.oceanBlue
    }
    
    fileprivate func setupCell(with item: HomeViewModelEventItem) {
        textLabel?.text = item.imageUrl
    }
}
