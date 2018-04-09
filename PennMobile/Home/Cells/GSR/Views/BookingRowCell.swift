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

internal typealias BookingOptions = (GSRTimeSlot?, GSRTimeSlot?, GSRTimeSlot?)

class BookingRowCell: UITableViewCell {
    
    static let rowHeight: CGFloat = 82.0
    
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
    
    var rowLabelText: String? {
        didSet {
            self.rowLabel.text = rowLabelText
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
        
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "h:m"
        
        if let _ = options.0 {
            bookingLabels.0!.text = formatter.string(from: options.0!.startTime)
            bookingButtons.0!.isEnabled = true
        } else {
            bookingLabels.0!.text = ""
            bookingButtons.0!.isEnabled = false
        }
        if let _ = options.1 {
            bookingLabels.1!.text = formatter.string(from: options.1!.startTime)
            bookingButtons.1!.isEnabled = true
        } else {
            bookingLabels.1!.text = ""
            bookingButtons.1!.isEnabled = false
        }
        if let _ = options.2 {
            bookingLabels.2!.text = formatter.string(from: options.0!.startTime)
            bookingButtons.2!.isEnabled = true
        } else {
            bookingLabels.2!.text = ""
            bookingButtons.2!.isEnabled = false
        }
        bookingIncrementLabels.2!.textColor = .allbirdsGrey
        
        bookingIncrementLabels.0!.text = "30'"
        bookingIncrementLabels.1!.text = "60'"
        bookingIncrementLabels.2!.text = "90'"
        
        updateButtonsUI()
    }
    
    fileprivate func updateButtonsUI() {
        if bookingButtons.0!.isEnabled {
            bookingIncrementLabels.0!.textColor = .interactionGreen
        } else {
            bookingIncrementLabels.0!.textColor = .allbirdsGrey
        }
        if bookingButtons.1!.isEnabled {
            bookingIncrementLabels.1!.textColor = .interactionGreen
        } else {
            bookingIncrementLabels.1!.textColor = .allbirdsGrey
        }
        if bookingButtons.2!.isEnabled {
            bookingIncrementLabels.2!.textColor = .interactionGreen
        } else {
            bookingIncrementLabels.2!.textColor = .allbirdsGrey
        }
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
        
        bookingLabels.0!.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -9).isActive = true
        bookingLabels.1!.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -9).isActive = true
        bookingLabels.2!.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -9).isActive = true
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
