//
//  BookingRowCell.swift
//  PennMobile
//
//  Created by dominic on 3/3/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//
import UIKit

struct StudyRoomBookingOption {
    let name: String?
    let duration: Int?
    let timeDescription: String?
}

internal typealias BookingOptions = (StudyRoomBookingOption?, StudyRoomBookingOption?, StudyRoomBookingOption?)

class BookingRowCell: UITableViewCell {
    
    static let rowHeight: CGFloat = 76.0
    
    fileprivate var rowLabel: UILabel!
    fileprivate var bookingLabels: (UILabel?, UILabel?, UILabel?)
    fileprivate var bookingButtons: (UIButton?, UIButton?, UIButton?)
    fileprivate var bookingIncrementLabels: (UILabel?, UILabel?, UILabel?)
    fileprivate let buttonSize: CGFloat = 53
    
    var bookingOptions: BookingOptions {
        didSet {
            setupCell(with: bookingOptions)
        }
    }
    
    // MARK: - Init
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        prepareUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc fileprivate func bookingButtonTapped() {
        print("Button Tapped!")
    }
}

extension BookingRowCell {
    fileprivate func setupCell(with options: BookingOptions) {
        
        rowLabel.text = "Booth"
        
        bookingLabels.0!.text = options.0?.timeDescription ?? ""
        bookingLabels.1!.text = options.1?.timeDescription ?? ""
        bookingLabels.2!.text = options.2?.timeDescription ?? ""
        
        bookingButtons.2!.isEnabled = false
        bookingIncrementLabels.2!.textColor = .allbirdsGrey
        
        bookingIncrementLabels.0!.text = "30'"
        bookingIncrementLabels.1!.text = "60'"
        bookingIncrementLabels.2!.text = "90'"
    }
}

// MARK: - Initialize & Layout UI Elements
extension BookingRowCell {
    
    fileprivate func prepareUI() {
        prepareLabels()
        prepareButtons()
        prepareIncrementLabels()
    }
    
    // MARK: Labels
    fileprivate func prepareLabels() {
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
        
        bookingLabels.0!.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -3).isActive = true
        bookingLabels.1!.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -3).isActive = true
        bookingLabels.2!.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -3).isActive = true
    }
    
    // MARK: Buttons
    fileprivate func prepareButtons() {
        bookingButtons = (getBookingButton(), getBookingButton(), getBookingButton())
        addSubview(bookingButtons.0!)
        addSubview(bookingButtons.1!)
        addSubview(bookingButtons.2!)
        
        bookingButtons.0!.widthAnchor.constraint(equalToConstant: buttonSize).isActive = true
        bookingButtons.0!.heightAnchor.constraint(equalToConstant: buttonSize).isActive = true
        bookingButtons.1!.widthAnchor.constraint(equalToConstant: buttonSize).isActive = true
        bookingButtons.1!.heightAnchor.constraint(equalToConstant: buttonSize).isActive = true
        bookingButtons.2!.widthAnchor.constraint(equalToConstant: buttonSize).isActive = true
        bookingButtons.2!.heightAnchor.constraint(equalToConstant: buttonSize).isActive = true
        
        bookingButtons.0!.topAnchor.constraint(equalTo: topAnchor, constant: 2).isActive = true
        bookingButtons.1!.topAnchor.constraint(equalTo: topAnchor, constant: 2).isActive = true
        bookingButtons.2!.topAnchor.constraint(equalTo: topAnchor, constant: 2).isActive = true
        
        bookingButtons.0!.centerXAnchor.constraint(equalTo: bookingLabels.0!.centerXAnchor).isActive = true
        bookingButtons.1!.centerXAnchor.constraint(equalTo: bookingLabels.1!.centerXAnchor).isActive = true
        bookingButtons.2!.centerXAnchor.constraint(equalTo: bookingLabels.2!.centerXAnchor).isActive = true
    }
    
    // MARK: Buttons
    fileprivate func prepareIncrementLabels() {
        bookingIncrementLabels = (getIncrementLabel(), getIncrementLabel(), getIncrementLabel())
        addSubview(bookingIncrementLabels.0!)
        addSubview(bookingIncrementLabels.1!)
        addSubview(bookingIncrementLabels.2!)
        
        bookingIncrementLabels.0!.widthAnchor.constraint(equalToConstant: buttonSize).isActive = true
        bookingIncrementLabels.0!.heightAnchor.constraint(equalToConstant: buttonSize).isActive = true
        bookingIncrementLabels.1!.widthAnchor.constraint(equalToConstant: buttonSize).isActive = true
        bookingIncrementLabels.1!.heightAnchor.constraint(equalToConstant: buttonSize).isActive = true
        bookingIncrementLabels.2!.widthAnchor.constraint(equalToConstant: buttonSize).isActive = true
        bookingIncrementLabels.2!.heightAnchor.constraint(equalToConstant: buttonSize).isActive = true
        
        bookingIncrementLabels.0!.topAnchor.constraint(equalTo: topAnchor, constant: 2).isActive = true
        bookingIncrementLabels.1!.topAnchor.constraint(equalTo: topAnchor, constant: 2).isActive = true
        bookingIncrementLabels.2!.topAnchor.constraint(equalTo: topAnchor, constant: 2).isActive = true
        
        bookingIncrementLabels.0!.centerXAnchor.constraint(equalTo: bookingLabels.0!.centerXAnchor, constant: 2).isActive = true
        bookingIncrementLabels.1!.centerXAnchor.constraint(equalTo: bookingLabels.1!.centerXAnchor, constant: 2).isActive = true
        bookingIncrementLabels.2!.centerXAnchor.constraint(equalTo: bookingLabels.2!.centerXAnchor, constant: 2).isActive = true
    }
}

// MARK: - Define UI Elements
extension BookingRowCell {
    
    fileprivate func getRowLabel() -> UILabel {
        let label = UILabel()
        label.font = .secondaryTitleFont
        label.textColor = .secondaryTitleGrey
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
    fileprivate func getTimeLabel() -> UILabel {
        let label = UILabel()
        label.font = .secondaryTitleFont
        label.textColor = .secondaryTitleGrey
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
    fileprivate func getBookingButton() -> UIButton {
        let button = UIButton()
        button.backgroundColor = .clear
        button.titleLabel?.font = .footerTransitionFont
        button.addTarget(self, action: #selector(bookingButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "Available-GSR"), for: .normal)
        button.setImage(UIImage(named: "Available-GSR-Enabled"), for: .selected)
        button.setImage(UIImage(named: "Available-GSR-Enabled"), for: .highlighted)
        button.setImage(UIImage(named: "Disabled-GSR"), for: .disabled)
        button.tintColor = .clear
        
        return button
    }
    
    fileprivate func getIncrementLabel() -> UILabel {
        let label = UILabel()
        label.font = .gsrTimeIncrementFont
        label.textColor = .interactionGreen
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
}
