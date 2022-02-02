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
    func handleBookingSelected(_ booking: GSRBooking)
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

    var bookingOptions: [[GSRBooking?]]?

    var cardView: UIView! = UIView()
    // Custom UI elements (some should be abstracted)
    fileprivate let safeInsetValue: CGFloat = 14
    fileprivate var safeArea: UIView!

    fileprivate var secondaryTitleLabel: UILabel!
    fileprivate var primaryTitleLabel: UILabel!

    fileprivate var dividerLine: UIView!

    fileprivate var bookingViewTop: UIView!
    fileprivate var bookingViewBottom: UIView!

    fileprivate var bookingRowViews: [UIView]!
    fileprivate var bookingButtons: [[HomeGSRBookingButton]]!
    fileprivate var bookingButtonTimeLabels: [[UILabel]]!
    fileprivate var bookingButtonRowLabels: [UILabel]!

    fileprivate var footerDescriptionLabel: UILabel!
    fileprivate var footerTransitionButton: UIButton!

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
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

    fileprivate func setupCell(with item: HomeGSRCellItem) {
        secondaryTitleLabel.text = "BOOK A ROOM"
        primaryTitleLabel.text = "Van Pelt - WIC"
        bookingOptions = item.bookingOptions
        updateBookingButtons()
        bookingButtonRowLabels[0].text = "Booths"
        bookingButtonRowLabels[1].text = "Rooms"
        footerDescriptionLabel.text = "Showing next available bookings."
    }

    fileprivate func updateBookingButtons() {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "h:mma"
        formatter.amSymbol = "a"
        formatter.pmSymbol = "p"

        for row in 0..<HomeStudyRoomCell.numberOfBookingCellRows {
            for n in 0..<3 {
                bookingButtons[row][n].booking = bookingOptions?[row][n]
                if let _ = bookingOptions, bookingOptions![row][n] != nil {
//                    bookingButtonTimeLabels[row][n].text = formatter.string(from: (bookingOptions![row][n]?.start)!)
                } else {
                    bookingButtonTimeLabels[row][n].text = ""
                }
            }
        }
    }
}

extension HomeStudyRoomCell : HomeGSRBookingButtonDelegate {
    func handleBookingSelected(_ booking: GSRBooking) {
        guard let delegate = delegate as? GSRBookingSelectable else { return }
        delegate.handleBookingSelected(booking)
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
        prepareBookingTimeLabels()
        prepareBookingButtons()
        prepareBookingRowLabels()
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
        bookingRowViews = [UIView]()
        for row in 0..<HomeStudyRoomCell.numberOfBookingCellRows {
            let bookingRowView = getBookingView()
            cardView.addSubview(bookingRowView)

            bookingRowView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor).isActive = true
            bookingRowView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor).isActive = true
            bookingRowView.heightAnchor.constraint(equalToConstant: HomeStudyRoomCell.bookingRowHeight).isActive = true

            if row == 0 {
                bookingRowView.topAnchor.constraint(equalTo: dividerLine.bottomAnchor, constant: safeInsetValue).isActive = true
            } else {
                bookingRowView.topAnchor.constraint(equalTo: bookingRowViews[row - 1].bottomAnchor).isActive = true
            }
            bookingRowViews.append(bookingRowView)
        }
    }

    fileprivate func prepareBookingTimeLabels() {
        bookingButtonTimeLabels = [[UILabel]]()
        for row in 0..<HomeStudyRoomCell.numberOfBookingCellRows {
            var timeLabels = [UILabel]()
            for _ in 0..<3 {
                let timeLabel = getBookingTimeLabel()
                cardView.addSubview(timeLabel)
                timeLabels.append(timeLabel)
            }
            timeLabels[0].leadingAnchor.constraint(equalTo: bookingRowViews[row].leadingAnchor,
                                                   constant: 47).isActive = true
            timeLabels[2].trailingAnchor.constraint(equalTo: bookingRowViews[row].trailingAnchor).isActive = true
            for n in 0..<3 {
                if n != 0 {
                    timeLabels[n].leadingAnchor.constraint(equalTo: timeLabels[n - 1].trailingAnchor).isActive = true
                    timeLabels[n].widthAnchor.constraint(equalTo: timeLabels[n - 1].widthAnchor).isActive = true
                }
                timeLabels[n].bottomAnchor.constraint(equalTo: bookingRowViews[row].bottomAnchor,
                                                      constant: -9).isActive = true
            }
            bookingButtonTimeLabels.append(timeLabels)
        }
    }

    fileprivate func prepareBookingButtons() {

        let buttonSize: CGFloat = 53

        bookingButtons = [[HomeGSRBookingButton]]()
        for row in 0..<HomeStudyRoomCell.numberOfBookingCellRows {
            var bookingRowButtons = [HomeGSRBookingButton]()
            for n in 0..<3 {
                let button = getBookingButton(n)
                bookingRowButtons.append(button)
                cardView.addSubview(button)
                button.widthAnchor.constraint(equalToConstant: buttonSize).isActive = true
                button.heightAnchor.constraint(equalToConstant: buttonSize).isActive = true
                button.topAnchor.constraint(equalTo: bookingRowViews[row].topAnchor, constant: 2).isActive = true
                button.centerXAnchor.constraint(equalTo: bookingButtonTimeLabels[row][n].centerXAnchor).isActive = true
            }
            bookingButtons.append(bookingRowButtons)
        }
    }

    fileprivate func prepareBookingRowLabels() {
        bookingButtonRowLabels = [UILabel]()
        for row in 0..<HomeStudyRoomCell.numberOfBookingCellRows {
            let rowLabel = getBookingRowLabel()
            bookingButtonRowLabels.append(rowLabel)
            cardView.addSubview(rowLabel)

            rowLabel.leadingAnchor.constraint(equalTo: bookingRowViews[row].leadingAnchor).isActive = true
            rowLabel.centerYAnchor.constraint(equalTo: bookingButtons[row][0].centerYAnchor).isActive = true
         }
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
        label.textColor = .labelSecondary
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }

    fileprivate func getPrimaryLabel() -> UILabel {
        let label = UILabel()
        label.font = .primaryTitleFont
        label.textColor = .labelPrimary
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }

    fileprivate func getDividerLine() -> UIView {
        let view = UIView()
        view.backgroundColor = .grey5
        view.layer.cornerRadius = 2.0
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    fileprivate func getBookingView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    }

    fileprivate func getBookingRowLabel() -> UILabel {
        let label = UILabel()
        label.font = .secondaryTitleFont
        label.textColor = .labelSecondary
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }

    fileprivate func getBookingTimeLabel() -> UILabel {
        let label = UILabel()
        label.font = .secondaryTitleFont
        label.textColor = .labelSecondary
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }

    fileprivate func getBookingButton(_ increment: Int) -> HomeGSRBookingButton {
        let button = HomeGSRBookingButton(withIncrement: increment)
        button.delegate = self
        return button
    }

    fileprivate func getFooterDescriptionLabel() -> UILabel {
        let label = UILabel()
        label.font = .secondaryTitleFont
        label.textColor = .labelSecondary
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }

    fileprivate func getFooterTransitionButton() -> UIButton {
        let button = UIButton()
        button.setTitleColor(.navigation, for: .normal)
        button.setTitleColor(.labelSecondary, for: .highlighted)
        //button.setTitle("See more ❯", for: .normal)
        button.titleLabel?.font = .footerTransitionFont
        button.addTarget(self, action: #selector(transitionButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }
}
