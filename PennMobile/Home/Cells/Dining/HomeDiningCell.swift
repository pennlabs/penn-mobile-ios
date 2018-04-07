//
//  HomeDiningCell.swift
//  PennMobile
//
//  Created by Josh Doman on 1/17/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//
import Foundation
import UIKit

protocol DiningCellSelectable {
    func handleVenueSelected(_ venue: DiningVenue)
}

final class HomeDiningCell: UITableViewCell, HomeCellConformable {
    var delegate: ModularTableViewCellDelegate!
    var item: ModularTableViewItem! {
        didSet {
            guard let item = item as? HomeDiningCellItem else { return }
            setupCell(with: item)
        }
    }
    
    static func getCellHeight(for item: ModularTableViewItem) -> CGFloat {
        guard let item = item as? HomeDiningCellItem else { return 0.0 }
        // cell height = (venues * venueHeight) + header + footer + cellInset
        return (CGFloat(item.venues.count) * DiningCell.cellHeight) + (90.0 + 38.0 + 20.0)
    }
    
    static var identifier: String = "diningCell"
    
    var venues: [DiningVenue]?
    
    var cardView: UIView! = UIView()
    
    // Custom UI elements (some should be abstracted)
    fileprivate let safeInsetValue: CGFloat = 14
    fileprivate var safeArea: UIView!
    
    fileprivate var secondaryTitleLabel: UILabel!
    fileprivate var primaryTitleLabel: UILabel!
    
    fileprivate var dividerLine: UIView!
    fileprivate var venueTableView: UITableView!
    
    fileprivate var footerDescriptionLabel: UILabel!
    fileprivate var footerTransitionButton: UIButton!
    
    // Mark: - Init
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        prepareHomeCell()
        prepareUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc fileprivate func transitionButtonTapped() {
        print("Button Tapped!")
    }
}

// MARK: - Setup UI Elements
extension HomeDiningCell {
    fileprivate func setupCell(with item: HomeDiningCellItem) {
        venues = item.venues
        venueTableView.reloadData()
        
        secondaryTitleLabel.text = "DINING HALLS"
        primaryTitleLabel.text = "Frequently Visited"
        
        footerDescriptionLabel.text = "Showing your most-visited halls."
    }
}

// MARK: - UITableViewDataSource
extension HomeDiningCell: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return venues?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: DiningCell.identifier, for: indexPath) as! DiningCell
        cell.venue = venues?[indexPath.row]
        return cell
    }
}

// MARK: - UITableViewDelegate
extension HomeDiningCell: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let venue = venues?[indexPath.row], let delegate = delegate as? DiningCellSelectable else { return }
        delegate.handleVenueSelected(venue)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return DiningCell.cellHeight
    }
}

// MARK: - Initialize & Layout UI Elements
extension HomeDiningCell {
    fileprivate func prepareUI() {
        prepareSafeArea()
        prepareTitleLabels()
        prepareDividerLine()
        prepareFooter()
        prepareTableView()
    }
    
    private func prepareSafeArea() {
        safeArea = getSafeAreaView()
        
        cardView.addSubview(safeArea)
        
        safeArea.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: safeInsetValue).isActive = true
        safeArea.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -safeInsetValue).isActive = true
        safeArea.topAnchor.constraint(equalTo: cardView.topAnchor, constant: safeInsetValue).isActive = true
        safeArea.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -safeInsetValue).isActive = true
    }
    
    // MARK: Labels
    fileprivate func prepareTitleLabels() {
        secondaryTitleLabel = getSecondaryLabel()
        primaryTitleLabel = getPrimaryLabel()
        
        cardView.addSubview(secondaryTitleLabel)
        cardView.addSubview(primaryTitleLabel)
        
        secondaryTitleLabel.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor).isActive = true
        secondaryTitleLabel.topAnchor.constraint(equalTo: safeArea.topAnchor).isActive = true
        
        primaryTitleLabel.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor).isActive = true
        primaryTitleLabel.topAnchor.constraint(equalTo: secondaryTitleLabel.bottomAnchor, constant: 10).isActive = true
    }
    
    // MARK: Divider Line
    fileprivate func prepareDividerLine() {
        dividerLine = getDividerLine()
        
        cardView.addSubview(dividerLine)
        
        dividerLine.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor).isActive = true
        dividerLine.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor).isActive = true
        dividerLine.topAnchor.constraint(equalTo: primaryTitleLabel.bottomAnchor, constant: 14).isActive = true
        dividerLine.heightAnchor.constraint(equalToConstant: 2).isActive = true
    }
    
    // MARK: Footer
    fileprivate func prepareFooter() {
        footerTransitionButton = getFooterTransitionButton()
        footerDescriptionLabel = getFooterDescriptionLabel()
        
        cardView.addSubview(footerTransitionButton)
        cardView.addSubview(footerDescriptionLabel)
        
        footerTransitionButton.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor).isActive = true
        footerTransitionButton.heightAnchor.constraint(equalToConstant: 26).isActive = true
        footerTransitionButton.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: 6).isActive = true
        
        footerDescriptionLabel.trailingAnchor.constraint(equalTo: footerTransitionButton.leadingAnchor,
                                                        constant: -10).isActive = true
        footerDescriptionLabel.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor).isActive = true
    }
    
    // Mark: TableView
    fileprivate func prepareTableView() {
        venueTableView = getVenueTableView()
        
        cardView.addSubview(venueTableView)
        
        venueTableView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor).isActive = true
        venueTableView.topAnchor.constraint(equalTo: dividerLine.bottomAnchor,
                                            constant: safeInsetValue / 2).isActive = true
        venueTableView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor).isActive = true
        venueTableView.bottomAnchor.constraint(equalTo: footerDescriptionLabel.topAnchor,
                                            constant: -safeInsetValue / 2).isActive = true
    }
}

// MARK: - Define UI Elements
extension HomeDiningCell {
    
    fileprivate func getSafeAreaView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    fileprivate func getSecondaryLabel() -> UILabel {
        let label = UILabel()
        label.font = .secondaryTitleFont
        label.textColor = .secondaryTitleGrey
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
    fileprivate func getPrimaryLabel() -> UILabel {
        let label = UILabel()
        label.font = .primaryTitleFont
        label.textColor = .primaryTitleGrey
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
    fileprivate func getDividerLine() -> UIView {
        let view = UIView()
        view.backgroundColor = .allbirdsGrey
        view.layer.cornerRadius = 2.0
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    fileprivate func getVenueTableView() -> UITableView {
        let tableView = UITableView()
        tableView.backgroundColor = .clear
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.isScrollEnabled = false
        tableView.register(DiningCell.self, forCellReuseIdentifier: DiningCell.identifier)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }
    
    fileprivate func getFooterDescriptionLabel() -> UILabel {
        let label = UILabel()
        label.font = .secondaryTitleFont
        label.textColor = .secondaryTitleGrey
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
    fileprivate func getFooterTransitionButton() -> UIButton {
        let button = UIButton()
        button.setTitleColor(.navigationBlue, for: .normal)
        button.setTitleColor(.secondaryTitleGrey, for: .highlighted)
        button.setTitle("See more ❯", for: .normal)
        button.titleLabel?.font = .footerTransitionFont
        button.addTarget(self, action: #selector(transitionButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }
}
