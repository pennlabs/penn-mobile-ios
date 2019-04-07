//
//  DiningBalanceCell.swift
//  PennMobile
//
//  Created by Marta García Ferreiro on 3/31/19.
//  Copyright © 2019 PennLabs. All rights reserved.
//

import Foundation

class DiningBalanceCell: UITableViewCell {
    
    static let identifier = "diningBalanceCell"
    static let cellHeight: CGFloat = 125
    
    var diningBalance: DiningBalance! {
        didSet {
            setupCell(with: diningBalance)
        }
    }
    
    fileprivate let collectionCellId: String = "diningBalanceCollectionViewCell"
    
    // MARK: - UI Elements
    fileprivate var balanceCollectionView: UICollectionView!
    fileprivate var balancesAsOfLabel: UILabel!
    fileprivate let safeInsetValue: CGFloat = 14
    fileprivate var safeArea: UIView!
    
    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        prepareUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Setup Cell
extension DiningBalanceCell {
    
    fileprivate func setupCell(with diningBalance: DiningBalance) {
        balancesAsOfLabel.text = diningBalance.balancesAsOf
        balanceCollectionView.reloadData()
    }
}

// MARK: - Initialize and Layout UI Elements
extension DiningBalanceCell {
    
    fileprivate func prepareUI() {
        prepareSafeArea()
        prepareCollectionView()
        prepareBalancesAsOfLabel()
    }
    
    fileprivate func prepareBalancesAsOfLabel() {
        balancesAsOfLabel = UILabel()
        balancesAsOfLabel.font = UIFont(name: "Avenir-Medium", size: 10)
        balancesAsOfLabel.textColor = .secondaryTitleGrey
        balancesAsOfLabel.textAlignment = .left
        balancesAsOfLabel.translatesAutoresizingMaskIntoConstraints = false
        balancesAsOfLabel.shrinkUntilFits()
        addSubview(balancesAsOfLabel)
        balancesAsOfLabel.topAnchor.constraint(equalTo: balanceCollectionView.bottomAnchor, constant: 3).isActive = true
        balancesAsOfLabel.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor).isActive = true
    }
    
    fileprivate func prepareCollectionView() {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.sectionInset = UIEdgeInsets(top: 3, left: 0, bottom: 3, right: 12)
        flowLayout.itemSize = CGSize(width: 132, height: 97)
        
        balanceCollectionView = UICollectionView(frame: safeArea.frame, collectionViewLayout: flowLayout)
    balanceCollectionView.register(DiningBalanceCollectionViewCell.self, forCellWithReuseIdentifier: collectionCellId)
        balanceCollectionView.backgroundColor = .clear
        balanceCollectionView.delegate = self
        balanceCollectionView.dataSource = self
        balanceCollectionView.showsHorizontalScrollIndicator = false
    
        balanceCollectionView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(balanceCollectionView)
        balanceCollectionView.topAnchor.constraint(equalTo: safeArea.topAnchor).isActive = true
        balanceCollectionView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor).isActive = true
        balanceCollectionView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        balanceCollectionView.heightAnchor.constraint(equalToConstant: 103).isActive = true
    }
    
    // MARK: Safe Area
    fileprivate func prepareSafeArea() {
        safeArea = UIView()
        safeArea.translatesAutoresizingMaskIntoConstraints = false
        addSubview(safeArea)
        
        safeArea.leadingAnchor.constraint(equalTo: leadingAnchor, constant: safeInsetValue).isActive = true
        safeArea.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -safeInsetValue).isActive = true
        safeArea.topAnchor.constraint(equalTo: topAnchor, constant: safeInsetValue / 2).isActive = true
        safeArea.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -safeInsetValue / 2).isActive = true
    }
}

// MARK: - CollectionView Delegate, Datasource

extension DiningBalanceCell: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: collectionCellId, for: indexPath as IndexPath) as! DiningBalanceCollectionViewCell
        cell.layer.cornerRadius = 8
//        cell.layer.shadowOffset = CGSize(width: 0, height: -2.0)
//        cell.layer.shadowRadius = 4
//        cell.layer.shadowOpacity = 1.0
//        cell.layer.shadowPath = UIBezierPath(roundedRect: cell.bounds, cornerRadius: cell.contentView.layer.cornerRadius).cgPath
        if (indexPath.item == 0) {
            cell.type = "Dining Dollars"
            cell.diningBalance = diningBalance
            cell.backgroundColor = UIColor.init(red: 106, green: 188, blue: 143)
        }
        if (indexPath.item == 1) {
            cell.type = "Swipes"
            cell.diningBalance = diningBalance
            cell.backgroundColor = UIColor.init(red: 106, green: 144, blue: 188)
        }
        if (indexPath.item == 2) {
            cell.type = "Guest Swipes"
            cell.diningBalance = diningBalance
            cell.backgroundColor = UIColor.init(red: 106 / 255, green: 144 / 255, blue: 188 / 255, alpha: 0.6)
        }
        return cell
    }
}

