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
    
    var menuItem: DiningMenuItem! {
        didSet {
            setupCell(with: menuItem)
        }
    }
    
    var station: DiningStation! {
        didSet {
            setupCell(with: station)
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
    fileprivate func setupCell(with item: DiningMenuItem) {
        nameLabel.text = item.name
        
        let types = item.specialties
        guard types.count > 0 else { return }
        
        for i in types.indices {
            if circleViews.indices.contains(i) {
                circleViews[i] = getCircleView(for: types[i])
            } else {
                circleViews.append(getCircleView(for: types[i]))
            }
        }
        
        layoutCircleViews()
    }
    
    fileprivate func setupCell(with station: DiningStation) {
        nameLabel.text = station.description
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
        
        _ = nameLabel.anchor(topAnchor, left: leftAnchor, bottom: bottomAnchor, right: nil, leftConstant: 30)
    }
    
    // MARK: Circle Views
    fileprivate func layoutCircleViews() {
        for i in circleViews.indices {
            guard let _ = circleViews[i] else { return }
            circleViews[i]!.frame = circleViews[i]!.frame.offsetBy(dx: 5.0 * CGFloat(i), dy: 0.0)
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
    
    fileprivate func getCircleView(for itemType: DiningMenuItemType) -> CircleColorView {
        switch itemType {
        case .vegetarian:   return CircleColorView(with: .green)
        case .vegan:        return CircleColorView(with: .purple)
        case .jain:         return CircleColorView(with: .yellow)
        case .seafood:      return CircleColorView(with: .blue)
        case .lowGluten:    return CircleColorView(with: .orange)
        }
    }
}

// MARK: - Circle View
class CircleColorView: UIView {
    private enum Constants {
        static let CircleDimensions = (w: 12, h: 12)
    }
    
    convenience init(with color: UIColor) {
        self.init(frame: CGRect(x: 0,
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
