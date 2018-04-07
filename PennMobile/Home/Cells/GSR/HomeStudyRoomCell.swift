//
//  HomeStudyRoomCell.swift
//  PennMobile
//
//  Created by Josh Doman on 1/17/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//

import Foundation
import UIKit

final class HomeStudyRoomCell: UITableViewCell, HomeCellConformable {
    
    static var identifier = "studyRoomCell"
    //static var cellHeight: CGFloat = 183.0 + (BookingRowCell.rowHeight * CGFloat(numberOfBookingCellRows))
    static private var numberOfBookingCellRows = 2
    static func getCellHeight(for item: ModularTableViewItem) -> CGFloat {
        return 183.0 + (BookingRowCell.rowHeight * CGFloat(numberOfBookingCellRows))
    }
    
    var delegate: ModularTableViewCellDelegate!
    var item: ModularTableViewItem! {
        didSet {
            guard let item = item as? HomeGSRCellItem else { return }
            setupCell(with: item)
        }
    }
    
    var cardView: UIView! = UIView()
    
    // Custom UI elements (some should be abstracted)
    fileprivate let safeInsetValue: CGFloat = 14
    fileprivate var safeArea: UIView!
    
    fileprivate var secondaryTitleLabel: UILabel!
    fileprivate var primaryTitleLabel: UILabel!
    
    fileprivate var dividerLine: UIView!
    
    fileprivate let bookingRowIdentifier = "StudyRoomBookingsRow"
    fileprivate var studyRoomTableView: UITableView!
    
    fileprivate var footerDescriptionLabel: UILabel!
    fileprivate var footerTransitionButton: UIButton!
    
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
    
    let option1 = StudyRoomBookingOption.init(name: nil, duration: nil, timeDescription: "5-6p")
    let option2 = StudyRoomBookingOption.init(name: nil, duration: nil, timeDescription: "7-8p")
    let option3 = StudyRoomBookingOption.init(name: nil, duration: nil, timeDescription: "9-10:30p")
}

// MARK: - Setup UI Elements
extension HomeStudyRoomCell {
    
    /*fileprivate func setupCell(with item: HomeViewModelStudyRoomItem) {
    }*/
    fileprivate func setupCell(with item: HomeGSRCellItem) {
        secondaryTitleLabel.text = "BOOK A ROOM"
        primaryTitleLabel.text = "Van Pelt Library"
        
        footerDescriptionLabel.text = "Showing next available bookings."
    }
}

// MARK: - tableView datasource
extension HomeStudyRoomCell: UITableViewDataSource {
    
    internal func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: bookingRowIdentifier) as? BookingRowCell
        cell?.bookingOptions = (option1, option2, option3)
        return cell!
    }
    
    internal func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return BookingRowCell.rowHeight
    }
}

// MARK: - tableView delegate
extension HomeStudyRoomCell: UITableViewDelegate {
    
}

// MARK: - Initialize & Layout UI Elements
extension HomeStudyRoomCell {
    
    fileprivate func prepareUI() {
        prepareSafeArea()
        prepareTitleLabels()
        prepareDividerLine()
        prepareFooter()
        prepareTableView()
    }
    
    // MARK: Safe Area
    fileprivate func prepareSafeArea() {
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
        studyRoomTableView = getStudyRoomTableView()
        
        cardView.addSubview(studyRoomTableView)
        
        studyRoomTableView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor).isActive = true
        studyRoomTableView.topAnchor.constraint(equalTo: dividerLine.bottomAnchor,
                                                constant: safeInsetValue).isActive = true
        studyRoomTableView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor).isActive = true
        studyRoomTableView.bottomAnchor.constraint(equalTo: footerDescriptionLabel.topAnchor,
                                                   constant: -safeInsetValue).isActive = true
    }
}

// MARK: - Define UI Elements
extension HomeStudyRoomCell {
    
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
    
    fileprivate func getStudyRoomTableView() -> UITableView {
        let tableView = UITableView()
        tableView.backgroundColor = .green
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.register(BookingRowCell.self, forCellReuseIdentifier: bookingRowIdentifier)
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
