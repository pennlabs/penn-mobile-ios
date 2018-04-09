//
//  HomeStudyRoomCell.swift
//  PennMobile
//
//  Created by Josh Doman on 1/17/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//

import Foundation
import UIKit

protocol GSRBookingSelectable {
    func handleVenueSelected(_ venue: DiningVenue)
}
final class HomeStudyRoomCell: UITableViewCell, HomeCellConformable {
    
    static var identifier = "studyRoomCell"

    fileprivate static let numberOfBookingCellRows = 2
    fileprivate static let bookingRowHeight : CGFloat = 82
    
    static func getCellHeight(for item: ModularTableViewItem) -> CGFloat {
        return 163.0 + (bookingRowHeight * CGFloat(numberOfBookingCellRows))
    }
    
    var delegate: ModularTableViewCellDelegate!
    var item: ModularTableViewItem! {
        didSet {
            guard let item = item as? HomeGSRCellItem else { return }
            setupCell(with: item)
        }
    }
    var bookingOptions: [(GSRTimeSlot?, GSRTimeSlot?, GSRTimeSlot?)]?
    
    var cardView: UIView! = UIView()
    // Custom UI elements (some should be abstracted)
    fileprivate let safeInsetValue: CGFloat = 14
    fileprivate var safeArea: UIView!
    
    fileprivate var secondaryTitleLabel: UILabel!
    fileprivate var primaryTitleLabel: UILabel!
    
    fileprivate var dividerLine: UIView!
    
    //fileprivate let bookingRowIdentifier = "StudyRoomBookingsRow"
    //fileprivate var studyRoomTableView: UITableView!
    
    fileprivate var bookingViewTop: UIView!
    fileprivate var bookingViewBottom: UIView!
    
    fileprivate var bookingButtons: [[HomeGSRBookingButton]]!
    fileprivate var bookingButtonTimeLabels: [[UILabel]]!
    fileprivate var bookingButtonRowLabels: [UILabel]!
    
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
}

// MARK: - Setup UI Elements
extension HomeStudyRoomCell {
    
    /*fileprivate func setupCell(with item: HomeViewModelStudyRoomItem) {
    }*/
    fileprivate func setupCell(with item: HomeGSRCellItem) {
        secondaryTitleLabel.text = "BOOK A ROOM"
        primaryTitleLabel.text = "Van Pelt Library"
        self.bookingOptions = item.bookingOptions
        footerDescriptionLabel.text = "Showing next available bookings."
    }
}

extension HomeStudyRoomCell : HomeGSRBookingButtonDelegate {
    func handleBookingSelected(_ booking: GSRBooking) {
        print("Handle booking!")
    }
}

// MARK: - Initialize & Layout UI Elements
extension HomeStudyRoomCell {
    
    fileprivate func prepareUI() {
        prepareSafeArea()
        prepareTitleLabels()
        prepareDividerLine()
        prepareFooter()
        prepareBookingViews()
        prepareBookingLabels()
        prepareBookingButtons()
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
    
    fileprivate func prepareBookingViews() {
        bookingViewTop = getBookingView()
        bookingViewBottom = getBookingView()
        
        cardView.addSubview(bookingViewTop)
        cardView.addSubview(bookingViewBottom)
        
        bookingViewTop.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor).isActive = true
        bookingViewTop.trailingAnchor.constraint(equalTo: safeArea.leadingAnchor).isActive = true
        bookingViewTop.topAnchor.constraint(equalTo: dividerLine.bottomAnchor,
                                            constant: safeInsetValue).isActive = true
        bookingViewTop.heightAnchor.constraint(equalToConstant: HomeStudyRoomCell.bookingRowHeight).isActive = true
        
        bookingViewBottom.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor).isActive = true
        bookingViewBottom.trailingAnchor.constraint(equalTo: safeArea.leadingAnchor).isActive = true
        bookingViewBottom.topAnchor.constraint(equalTo: bookingViewTop.bottomAnchor).isActive = true
        bookingViewBottom.heightAnchor.constraint(equalTo: bookingViewTop.heightAnchor).isActive = true
        
    }
    
    fileprivate func prepareBookingLabels() {
        for row in 0..<HomeStudyRoomCell.numberOfBookingCellRows {
            
        }
        /*
        rowLabel = getRowLabel()
        addSubview(rowLabel)
        
        rowLabel.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        rowLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        bookingLabels = (getTimeLabel(), getTimeLabel(), getTimeLabel())
        addSubview(bookingLabels.0!)
        addSubview(bookingLabels.1!)
        addSubview(bookingLabels.2!)
        
        bookingLabels.0!.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 47).isActive = true
        bookingLabels.1!.leadingAnchor.constraint(equalTo: bookingLabels.0!.trailingAnchor).isActive = true
        bookingLabels.2!.leadingAnchor.constraint(equalTo: bookingLabels.1!.trailingAnchor).isActive = true
        bookingLabels.2!.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        
        bookingLabels.0!.widthAnchor.constraint(equalTo: bookingLabels.1!.widthAnchor).isActive = true
        bookingLabels.1!.widthAnchor.constraint(equalTo: bookingLabels.2!.widthAnchor).isActive = true
        
        bookingLabels.0!.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -9).isActive = true
        bookingLabels.1!.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -9).isActive = true
        bookingLabels.2!.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -9).isActive = true*/
    }
    
    fileprivate func prepareBookingButtons() {
    }
    
    /*// Mark: TableView
    fileprivate func prepareTableView() {
        studyRoomTableView = getStudyRoomTableView()
        
        cardView.addSubview(studyRoomTableView)
        
        studyRoomTableView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor).isActive = true
        studyRoomTableView.topAnchor.constraint(equalTo: dividerLine.bottomAnchor,
                                                constant: safeInsetValue).isActive = true
        studyRoomTableView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor).isActive = true
        studyRoomTableView.bottomAnchor.constraint(equalTo: footerDescriptionLabel.topAnchor,
                                                   constant: -safeInsetValue).isActive = true
    }*/
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
    
    fileprivate func getBookingView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .red
        return view
    }
    
    fileprivate func getBookingRowLabel() -> UILabel {
        let label = UILabel()
        label.font = .secondaryTitleFont
        label.textColor = .secondaryTitleGrey
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
    fileprivate func getBookingTimeLabel() -> UILabel {
        let label = UILabel()
        label.font = .secondaryTitleFont
        label.textColor = .secondaryTitleGrey
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
    fileprivate func getBookingButton() -> HomeGSRBookingButton {
        let button = HomeGSRBookingButton()
        return button
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
