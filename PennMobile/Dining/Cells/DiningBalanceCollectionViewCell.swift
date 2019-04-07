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
    
    var type: String! {
        didSet {
            if let type = type {
                setupCell(with: type)
            }
        }
    }
    var diningBalance: DiningBalance! {
        didSet {
            setupCellData(with: diningBalance)
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
    
    fileprivate func setupCell(with type: String) {
        titleLabel.text = type
    }
    fileprivate func setupCellData(with balance: DiningBalance) {
        titleLabel.text = type
        if (type == "Dining Dollars") {
            dataLabel.text = balance.diningDollars
            icon.image = UIImage(named: "coin")
        }
        if (type == "Swipes") {
            dataLabel.text = String (balance.totalVisits!)
            icon.image = UIImage(named: "card")
        }
        if (type == "Guest Swipes") {
            dataLabel.text = String (balance.guestVisits!)
            icon.image = UIImage(named: "friends")
        }
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
        
        safeArea.leadingAnchor.constraint(equalTo: leadingAnchor, constant: safeInsetValue).isActive = true
        safeArea.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -safeInsetValue).isActive = true
        safeArea.topAnchor.constraint(equalTo: topAnchor, constant: safeInsetValue / 2).isActive = true
        safeArea.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -safeInsetValue / 2).isActive = true
    }
    
    // MARK: ImageView
    fileprivate func prepareImageView() {
        icon = getImageView()
        addSubview(icon)
        icon.widthAnchor.constraint(equalToConstant: 20).isActive = true
        icon.heightAnchor.constraint(equalToConstant: 12).isActive = true
        icon.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor).isActive = true
        icon.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -3).isActive = true
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
        label.font = UIFont(name: "Avenir-Medium", size: 12)
        label.textColor = .white
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        label.shrinkUntilFits()
        return label
    }
    
    fileprivate func getDataLabel() -> UILabel {
        let label = UILabel()
        label.font = UIFont(name: "Avenir-Heavy", size: 24)
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.shrinkUntilFits()
        return label
    }
}
