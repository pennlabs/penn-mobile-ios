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
    static let cellHeight: CGFloat = 100
    
    var diningBalances: DiningBalances! {
        didSet {
            setupCell(with: diningBalances)
        }
    }
    
    // MARK: - UI Elements
    fileprivate let safeInsetValue: CGFloat = 14
    fileprivate var safeArea: UIView!
    
    fileprivate var venueImageView: UIImageView!
    fileprivate var diningPlanLabel: UILabel!
    fileprivate var diningDollarsLabel: UILabel!
    fileprivate var visitsLabel: UILabel!
    fileprivate var guestVisitsLabel: UILabel!
    
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
        diningPlanLabel.text = "Dining Plan: " + diningBalances.planName!
        diningDollarsLabel.text = "Dining Dollars: " + diningBalances.diningDollars!
        visitsLabel.text = "Swipes: " + String (diningBalances.visits!)
        guestVisitsLabel.text = "Guest Swipes: " + String (diningBalances.guestVisits!)
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
        venueImageView.heightAnchor.constraint(equalToConstant: 72).isActive = true
        venueImageView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor).isActive = true
        venueImageView.centerYAnchor.constraint(equalTo: safeArea.centerYAnchor).isActive = true
    }
    
    fileprivate func getVenueImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 5.0
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }
    
    // MARK: Labels
    fileprivate func prepareLabels() {
        diningPlanLabel = getDiningPlanLabel()
        addSubview(diningPlanLabel)
        diningDollarsLabel = getDiningDollarsLabel()
        addSubview(diningDollarsLabel)
        visitsLabel = getVisitsLabel()
        addSubview(visitsLabel)
        guestVisitsLabel = getGuestVisitsLabel()
        addSubview(guestVisitsLabel)
        
        diningPlanLabel.leadingAnchor.constraint(equalTo: venueImageView.trailingAnchor, constant: safeInsetValue).isActive = true
        diningPlanLabel.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 3).isActive = true
        
        diningDollarsLabel.leadingAnchor.constraint(equalTo: diningPlanLabel.leadingAnchor).isActive = true
        diningDollarsLabel.topAnchor.constraint(equalTo: diningPlanLabel.bottomAnchor, constant: 3).isActive = true
        
        visitsLabel.leadingAnchor.constraint(equalTo: diningPlanLabel.leadingAnchor).isActive = true
        visitsLabel.topAnchor.constraint(equalTo: diningDollarsLabel.bottomAnchor, constant: 3).isActive = true
        
        guestVisitsLabel.leadingAnchor.constraint(equalTo: diningPlanLabel.leadingAnchor).isActive = true
        guestVisitsLabel.topAnchor.constraint(equalTo: visitsLabel.bottomAnchor, constant: 3).isActive = true
    }
    
    fileprivate func getSafeAreaView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    fileprivate func getDiningPlanLabel() -> UILabel {
        let label = UILabel()
        label.font = .interiorTitleFont
        label.textColor = .primaryTitleGrey
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        label.shrinkUntilFits()
        return label
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
}

