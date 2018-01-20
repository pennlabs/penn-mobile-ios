//
//  HomeLaundryCell.swift
//  PennMobile
//
//  Created by Josh Doman on 1/17/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//

import Foundation
import UIKit

class HomeLaundryCell: GeneralHomeCell, Transitionable {
    
    static let identifier = "laundryCell"
    static let cellHeight: CGFloat = 200.0

    var transitionButton: UIButton!

    override var item: HomeViewModelItem? {
        didSet {
            guard let item = item as? HomeViewModelLaundryItem else { return }
            setupCell(with: item)
        }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        prepareTransitionButton()
        prepareTextLabel()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Setup and Prepare UI Elements
extension HomeLaundryCell {
    fileprivate func prepareTextLabel() {
        textLabel?.textColor = UIColor.coral
        textLabel?.numberOfLines = 3
    }
    
    fileprivate func setupCell(with item: HomeViewModelLaundryItem) {
        textLabel?.text = String(item.rooms.map {
                var numberRunning = 0
                $0.washers.forEach { if $0.status == .running { numberRunning += 1 } }
                $0.dryers.forEach { if $0.status == .running { numberRunning += 1 } }
                let str = numberRunning > 0 ? " - \(numberRunning) running" : ""
                return $0.name + str + "\n"
            }.joined().dropLast())
    }
}
