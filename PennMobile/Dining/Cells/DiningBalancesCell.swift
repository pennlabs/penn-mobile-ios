//
//  DiningBalancesCell.swift
//  PennMobile
//
//  Created by Marta García Ferreiro on 3/31/19.
//  Copyright © 2019 PennLabs. All rights reserved.
//

import Foundation

class DiningBalancesCell: UITableViewCell {
    
    static let identifier = "diningBalancesCell"
    static let cellHeight: CGFloat = 130
    
    var diningBalances: DiningBalances! {
        didSet {
            setupCell(with: diningBalances)
        }
    }
    
    // MARK: - UI Elements
    fileprivate let safeInsetValue: CGFloat = 14
    fileprivate var safeArea: UIView!
    
    fileprivate var venueImageView: UIImageView!
    fileprivate var diningDollarsLabel: UILabel!
    fileprivate var visitsLabel: UILabel!
    fileprivate var guestVisitsLabel: UILabel!
    fileprivate var balancesAsOfLabel: UILabel!
    
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
extension DiningBalancesCell {
    
    fileprivate func setupCell(with diningBalances: DiningBalances) {
        diningDollarsLabel.text = "Dining Dollars: " + diningBalances.diningDollars!
        visitsLabel.text = "Swipes: " + String (diningBalances.totalVisits!)
        guestVisitsLabel.text = "Guest Swipes: " + String (diningBalances.guestVisits!)
        balancesAsOfLabel.text = diningBalances.balancesAsOf!
        venueImageView.image = UIImage(named: "1920 Commons")
    }
}

// MARK: - Initialize and Layout UI Elements
extension DiningBalancesCell {
    
    fileprivate func prepareUI() {
        prepareSafeArea()
        prepareImageView()
        prepareLabels()
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
        venueImageView = getVenueImageView()
        addSubview(venueImageView)
        venueImageView.widthAnchor.constraint(equalToConstant: 130).isActive = true
        venueImageView.heightAnchor.constraint(equalToConstant: 85).isActive = true
        venueImageView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor).isActive = true
        venueImageView.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 3).isActive = true
    }
    
    // MARK: Labels
    fileprivate func prepareLabels() {
        diningDollarsLabel = getDiningDollarsLabel()
        addSubview(diningDollarsLabel)
        visitsLabel = getVisitsLabel()
        addSubview(visitsLabel)
        guestVisitsLabel = getGuestVisitsLabel()
        addSubview(guestVisitsLabel)
        balancesAsOfLabel = getBalancesAsOfLabel()
        addSubview(balancesAsOfLabel)
        
        diningDollarsLabel.leadingAnchor.constraint(equalTo: venueImageView.trailingAnchor, constant: safeInsetValue).isActive = true
        diningDollarsLabel.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 3).isActive = true
        
        visitsLabel.leadingAnchor.constraint(equalTo: diningDollarsLabel.leadingAnchor).isActive = true
        visitsLabel.topAnchor.constraint(equalTo: diningDollarsLabel.bottomAnchor, constant: 2).isActive = true
        
        guestVisitsLabel.leadingAnchor.constraint(equalTo: diningDollarsLabel.leadingAnchor).isActive = true
        guestVisitsLabel.topAnchor.constraint(equalTo: visitsLabel.bottomAnchor, constant: 2).isActive = true
        
        balancesAsOfLabel.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor).isActive = true
        balancesAsOfLabel.topAnchor.constraint(equalTo: venueImageView.bottomAnchor, constant: 7).isActive = true
        balancesAsOfLabel.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -3).isActive = true
    }
    
    // MARK: Get UI elements
    fileprivate func getSafeAreaView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    fileprivate func getVenueImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 5.0
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }
    
    fileprivate func getDiningDollarsLabel() -> UILabel {
        let label = UILabel()
        label.font = .interiorTitleFont
        label.textColor = .primaryTitleGrey
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        label.shrinkUntilFits()
        return label
    }
    
    fileprivate func getVisitsLabel() -> UILabel {
        let label = UILabel()
        label.font = .interiorTitleFont
        label.textColor = .primaryTitleGrey
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        label.shrinkUntilFits()
        return label
    }
    
    fileprivate func getGuestVisitsLabel() -> UILabel {
        let label = UILabel()
        label.font = .interiorTitleFont
        label.textColor = .primaryTitleGrey
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        label.shrinkUntilFits()
        return label
    }
    
    fileprivate func getBalancesAsOfLabel() -> UILabel {
        let label = UILabel()
        label.font = .secondaryInformationFont
        label.textColor = .secondaryInformationGrey
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        label.shrinkUntilFits()
        return label
    }
}

