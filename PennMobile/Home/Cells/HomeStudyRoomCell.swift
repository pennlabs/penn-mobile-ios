//
//  HomeStudyRoomCell.swift
//  PennMobile
//
//  Created by Josh Doman on 1/17/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//

import Foundation
import UIKit

class HomeStudyRoomCell: GeneralHomeCell, Transitionable {
    
    static let identifier = "studyRoomCell"
    static let cellHeight: CGFloat = 60.0
    
    var transitionButton: UIButton!
    
    override var item: HomeViewModelItem? {
        didSet {
            guard let item = item as? HomeViewModelStudyRoomItem else { return }
            setupCell(with: item)
        }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        prepareTransitionButton()
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
