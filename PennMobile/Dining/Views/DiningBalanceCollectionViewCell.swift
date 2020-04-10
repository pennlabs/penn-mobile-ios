//
//  DiningBalanceCollectionViewCell.swift
//  PennMobile
//
//  Created by Marta García Ferreiro on 4/7/19.
//  Copyright © 2019 PennLabs. All rights reserved.
//

import Foundation

class DiningBalanceCollectionViewCell: UICollectionViewCell {
    static let identifier = "diningBalanceCollectionViewCell"
    
    enum CellType {
        case diningDollars
        case swipes
        case guestSwipes
    }
    
    var type: CellType! {
        didSet {
            if let type = type {
                setupCell(with: type)
            }
        }
    }
    
    var value: String? {
        didSet {
            if let value = value {
                self.setupCellData(with: value)
            }
        }
    }
    
    fileprivate var titleLabel: UILabel!
    fileprivate var dataLabel: UILabel!
    fileprivate var icon: UIImageView!
    fileprivate var safeArea: UIView!
    
    fileprivate let safeInsetValue: CGFloat = 14
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.clear
        prepareUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Setup Cell
extension DiningBalanceCollectionViewCell {
    
    fileprivate func setupCell(with type: CellType) {
        if (type == .diningDollars) {
            titleLabel.text = "Dining Dollars"
            icon.image = UIImage(named: "coin")
        }
        if (type == .swipes) {
            titleLabel.text = "Swipes"
            icon.image = UIImage(named: "card")
        }
        if (type == .guestSwipes) {
            titleLabel.text = "Guest Swipes"
            icon.image = UIImage(named: "friends")
        }
    }
    fileprivate func setupCellData(with value: String?) {
        dataLabel.text = value
    }
}

// MARK: - Initialize and Layout UI Elements
extension DiningBalanceCollectionViewCell {
    
    fileprivate func prepareUI() {
        prepareSafeArea()
        prepareLabels()
        prepareImageView()
    }
    
    // MARK: Safe Area
    fileprivate func prepareSafeArea() {
        safeArea = getSafeAreaView()
        addSubview(safeArea)
        
        safeArea.leadingAnchor.constraint(equalTo: leadingAnchor, constant: safeInsetValue / 2).isActive = true
        safeArea.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -safeInsetValue / 2).isActive = true
        safeArea.topAnchor.constraint(equalTo: topAnchor, constant: safeInsetValue / 2).isActive = true
        safeArea.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -safeInsetValue / 2).isActive = true
    }
    
    // MARK: ImageView
    fileprivate func prepareImageView() {
        icon = getImageView()
        addSubview(icon)
        icon.widthAnchor.constraint(equalToConstant: 21).isActive = true
        icon.heightAnchor.constraint(equalToConstant: 21).isActive = true
        icon.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor).isActive = true
        icon.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: 2).isActive = true
    }
    
    // MARK: Labels
    fileprivate func prepareLabels() {
        titleLabel = getTitleLabel()
        addSubview(titleLabel)
        dataLabel = getDataLabel()
        addSubview(dataLabel)
        
        titleLabel.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor).isActive = true
        titleLabel.topAnchor.constraint(equalTo: safeArea.topAnchor).isActive = true
        
        dataLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        dataLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }
    
    // MARK: Get UI elements
    fileprivate func getSafeAreaView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    fileprivate func getImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }
    
    fileprivate func getTitleLabel() -> UILabel {
        let label = UILabel()
        label.font = .secondaryTitleFont
        label.textColor = .white
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        label.shrinkUntilFits()
        return label
    }
    
    fileprivate func getDataLabel() -> UILabel {
        let label = UILabel()
        label.font = .primaryTitleFont
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.shrinkUntilFits()
        return label
    }
}
