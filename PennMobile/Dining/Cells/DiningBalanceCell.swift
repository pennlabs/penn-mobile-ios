//
//  DiningBalanceCell.swift
//  PennMobile
//
//  Created by Marta García Ferreiro on 3/31/19.
//  Copyright © 2019 PennLabs. All rights reserved.
//

import Foundation

// MARK: - DiningBalanceCell Delegate

protocol DiningBalanceCellDelegate: class {
    func updateBalance()
}

class DiningBalanceCell: UITableViewCell {
    
    weak var delegate: DiningBalanceCellDelegate?
    
    static let identifier = "diningBalanceCell"
    static let cellHeight: CGFloat = 121
    
    var diningBalance: DiningBalance! {
        didSet {
            setupCell(with: diningBalance)
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
    fileprivate var refreshButton: UIButton!
    fileprivate var loadingView: UIActivityIndicatorView!
    
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
        diningDollarsLabel.text = "Dining Dollars: " + diningBalance.diningDollars!
        visitsLabel.text = "Swipes: " + String (diningBalance.visits!)
        guestVisitsLabel.text = "Guest Swipes: " + String (diningBalance.guestVisits!)
        balancesAsOfLabel.text = diningBalance.balancesAsOf!
        venueImageView.image = UIImage(named: "1920 Commons")
    }
}

// MARK: - Initialize and Layout UI Elements
extension DiningBalanceCell {
    
    fileprivate func prepareUI() {
        prepareSafeArea()
        prepareImageView()
        prepareLabels()
        prepareRefreshButton()
        prepareLoadingView()
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
        balancesAsOfLabel.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor).isActive = true
    }
    
    // MARK: Refresh Button
    fileprivate func prepareRefreshButton() {
        refreshButton = UIButton()
        refreshButton.tintColor = UIColor.navigationBlue
        refreshButton.setImage(UIImage(named: "refresh")?.withRenderingMode(.alwaysTemplate), for: .normal)
        refreshButton.addTarget(self, action: #selector(refreshButtonTapped(_:)), for: .touchUpInside)
        refreshButton.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(refreshButton)
        
        refreshButton.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor).isActive = true
        refreshButton.topAnchor.constraint(equalTo: safeArea.topAnchor).isActive = true
        refreshButton.widthAnchor.constraint(equalToConstant: 20).isActive = true
        refreshButton.heightAnchor.constraint(equalToConstant: 20).isActive = true
    }
    
    // MARK: Loading Indicator
    func prepareLoadingView() {
        loadingView = UIActivityIndicatorView(style: .whiteLarge)
        loadingView.color = .black
        loadingView.isHidden = true
        addSubview(loadingView)
        loadingView.translatesAutoresizingMaskIntoConstraints = false
        loadingView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor).isActive = true
        loadingView.topAnchor.constraint(equalTo: refreshButton.bottomAnchor).isActive = true
        loadingView.widthAnchor.constraint(equalToConstant: 50).isActive = true
        loadingView.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    func startLoadingViewAnimation() {
        self.loadingView.isHidden = false
        loadingView.startAnimating()
    }
    
    func stopLoadingViewAnimation() {
        self.loadingView.isHidden = true
        self.loadingView.stopAnimating()
    }
    
    @objc private func refreshButtonTapped(_ sender: Any) {
        startLoadingViewAnimation()
        delegate?.updateBalance()
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
