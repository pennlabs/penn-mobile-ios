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
    static var identifier = "studyRoomCell"
    static var cellHeight: CGFloat = 200.0
    static func getCellHeight(for item: HomeViewModelItem) -> CGFloat {
        return cellHeight
    }
    
    var delegate: HomeCellDelegate!
    var item: HomeViewModelItem? {
        didSet {
            guard let item = item as? HomeViewModelStudyRoomItem else { return }
            setupCell(with: item)
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
    fileprivate func setupCell(with item: HomeViewModelStudyRoomItem) {
        textLabel?.text = item.title
    }
}
