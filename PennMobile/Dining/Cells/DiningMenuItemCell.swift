//
//  DiningMenuItemCell.swift
//  PennMobile
//
//  Created by dominic on 6/26/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//

import UIKit

class DiningMenuItemCell: UITableViewCell {
    
    static let identifier = "DiningMenuItemCell"
    static let cellHeight: CGFloat = 20
    
    var menuItem: MenuItem! {
        didSet {
            setupCell(with: menuItem)
        }
    }
    
    // MARK: - UI Elements
    fileprivate var nameLabel: UILabel!
    fileprivate var circleViews: [CircleColorView?] = [CircleColorView?]()
    
    // MARK: - Init
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        prepareUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Setup Cell
extension DiningMenuItemCell {
    fileprivate func setupCell(with item: MenuItem) {
        nameLabel.text = item.title
        
        guard let types = item.attributes else { return }
        
        for i in types.attributes.indices {
            if circleViews.indices.contains(i) {
                circleViews[i] = getCircleView(for: types.attributes[i])
            } else {
                circleViews.append(getCircleView(for: types.attributes[i]))
            }
        }
        
        layoutCircleViews()
    }
}

// MARK: - Initialize and Layout UI Elements
extension DiningMenuItemCell {
    
    fileprivate func prepareUI() {
        prepareLabels()
    }
    
    // MARK: Labels
    fileprivate func prepareLabels() {
        nameLabel = getNameLabel()
        addSubview(nameLabel)
        
        _ = nameLabel.anchor(topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor)
    }
    
    // MARK: Circle Views
    fileprivate func layoutCircleViews() {
        for i in circleViews.indices {
            // Limit number of circles to 3
            guard let _ = circleViews[i], i <= 4 else { break }
            circleViews[i]!.frame = circleViews[i]!.frame.offsetBy(dx: -8.0 * CGFloat(i), dy: 0.0)
            addSubview(circleViews[i]!)
        }
    }
}

// MARK: - Define UI Elements
extension DiningMenuItemCell {
    fileprivate func getNameLabel() -> UILabel {
        let label = UILabel()
        label.font = .secondaryInformationFont
        label.textColor = .primaryTitleGrey
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        label.shrinkUntilFits()
        return label
    }
    
    fileprivate func getCircleView(for itemType: DiningAttribute) -> CircleColorView {
        // Get bounds, taking into account the safe area insets of parent cell
        let maxX = Int(frame.maxX - 14.0)
        return CircleColorView(with: itemType.description.getColor(), startingX: maxX)
    }
}

// MARK: - Circle View
class CircleColorView: UIView {
    private enum Constants {
        static let CircleDimensions = (w: 10, h: 10)
    }
    
    convenience init(with color: UIColor, startingX: Int) {
        self.init(frame: CGRect(x: startingX,
                                y: Int(DiningMenuItemCell.cellHeight / 2) - Int(Constants.CircleDimensions.h / 2),
                                width: Constants.CircleDimensions.w,
                                height: Constants.CircleDimensions.h))
        self.backgroundColor = color
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.size.width / 2
        layer.masksToBounds = true
    }
}
