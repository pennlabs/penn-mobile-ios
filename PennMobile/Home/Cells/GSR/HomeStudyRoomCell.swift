//
//  HomeStudyRoomCell.swift
//  PennMobile
//
//  Created by Josh Doman on 1/17/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//

import Foundation
import UIKit

final class HomeStudyRoomCell: UITableViewCell, HomeCellConformable {
    static var identifier: String = "homeGSRCell"
    static func getCellHeight(for item: ModularTableViewItem) -> CGFloat {
        return 200.0
    }
    
    var delegate: ModularTableViewCellDelegate!
    var item: ModularTableViewItem! {
        didSet {
            
        }
    }
    
    var cardView: UIView! = UIView()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        prepareHomeCell()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Setup and Prepare UI Elements
extension HomeStudyRoomCell {
    fileprivate func setupCell(with item: HomeStudyRoomCell) {
//        textLabel?.text = item.title
    }
}
