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
    static let cellHeight: CGFloat = 120
    
    var diningBalance: DiningBalance? {
        didSet {
            setupCell(with: diningBalance)
        }
    }
    
    weak var transactionCellDelegate: TransactionCellDelegate?
    
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
    fileprivate func setupCell(with diningBalance: DiningBalance?) {
        if diningBalance == nil {
            balancesAsOfLabel.text = ""
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "h:mm a MM/dd/yy"
            let lastUpdated = "Last updated " + formatter.string(from: diningBalance!.lastUpdated)
            balancesAsOfLabel.text = lastUpdated
        }
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
        balancesAsOfLabel.font = .secondaryTitleFont
        balancesAsOfLabel.textColor = .labelSecondary
        balancesAsOfLabel.textAlignment = .left
        balancesAsOfLabel.translatesAutoresizingMaskIntoConstraints = false
        balancesAsOfLabel.shrinkUntilFits()
        addSubview(balancesAsOfLabel)
        balancesAsOfLabel.topAnchor.constraint(equalTo: balanceCollectionView.bottomAnchor, constant: 3).isActive = true
        balancesAsOfLabel.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 14).isActive = true
    }
    
    fileprivate func prepareCollectionView() {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 14, bottom: 0, right: 14)
        let width = (bounds.width + 6) / 3
        flowLayout.itemSize = CGSize(width: width, height: 88)

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
        balanceCollectionView.heightAnchor.constraint(equalToConstant: 95).isActive = true
        balanceCollectionView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor).isActive = true
    }
    
    // MARK: Safe Area
    fileprivate func prepareSafeArea() {
        safeArea = UIView()
        safeArea.translatesAutoresizingMaskIntoConstraints = false
        addSubview(safeArea)
        
        safeArea.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        safeArea.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
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
        cell.layer.shadowOffset = CGSize(width: 0.5, height: 1.0)
        cell.layer.shadowRadius = 1
        cell.layer.shadowColor = UIColor.grey1.cgColor
        cell.layer.shadowOpacity = 0.5
        cell.layer.shadowPath = UIBezierPath(roundedRect: cell.bounds, cornerRadius: 8).cgPath
        
        if (indexPath.item == 0) {
            cell.type = .diningDollars
            if let diningDollars = diningBalance?.diningDollars {
                cell.value = "$" + String(diningDollars)
            } else {
                cell.value = nil
            }
            cell.backgroundColor = UIColor.init(red: 106, green: 188, blue: 143)
        }
        if (indexPath.item == 1) {
            cell.type = .swipes
            if let visits = diningBalance?.visits {
                cell.value = String(visits)
            } else {
                cell.value = nil
            }
            cell.backgroundColor = UIColor.init(red: 106, green: 144, blue: 188)
        }
        if (indexPath.item == 2) {
            cell.type = .guestSwipes
            if let guestVisits = diningBalance?.guestVisits {
                cell.value = String(guestVisits)
            } else {
                cell.value = nil
            }
            cell.backgroundColor = UIColor.init(red: 0xA6, green: 0xBC, blue: 0xD7)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.item  == 0 {
            transactionCellDelegate?.userDidSelect()
        }
    }
}
