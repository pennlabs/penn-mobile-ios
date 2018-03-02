//
//  HomeDiningCell.swift
//  PennMobile
//
//  Created by Josh Doman on 1/17/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//

import Foundation
import UIKit

final class HomeDiningCell: UITableViewCell, HomeCellConformable {
    static var identifier: String = "diningCell"
    static var cellHeight: CGFloat = 200.0
    
    var delegate: HomeCellDelegate!
    var item: HomeViewModelItem? {
        didSet {
            guard let item = item as? HomeViewModelDiningItem else { return }
            setupCell(with: item)
        }
    }
    
    var cardView: UIView! = UIView()

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
extension HomeDiningCell {
    fileprivate func prepareTextLabel() {
        textLabel?.textColor = UIColor.buttonBlue
        textLabel?.numberOfLines = 3
    }
    
    fileprivate func setupCell(with item: HomeViewModelDiningItem) {
        textLabel?.text = String(item.venues.map {
            let timesStr = $0.times?.strFormat ?? ""
            return $0.name + "  " + timesStr + "\n"
            }.joined().dropLast())
    }
}
