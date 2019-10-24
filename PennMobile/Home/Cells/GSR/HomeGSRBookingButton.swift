//
//  HomeGSRBookingButton.swift
//  PennMobile
//
//  Created by dominic on 4/9/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//

import Foundation

protocol HomeGSRBookingButtonDelegate {
    func handleBookingSelected(_ booking: GSRBooking)
}
class HomeGSRBookingButton : UIButton {
    
    var booking : GSRBooking? {
        didSet {
            self.isEnabled = (booking != nil)
            if isEnabled {
                incrementLabel.textColor = .baseGreen
            } else {
                incrementLabel.textColor = .grey5
            }
        }
    }
    var delegate : HomeGSRBookingButtonDelegate?
    var incrementLabel : UILabel!
    
    convenience init(withIncrement increment: Int) {
        self.init()
        setupButton()
        setupIncrementLabel(increment)
    }
    
    private func setupButton() {
        backgroundColor = .clear
        titleLabel?.font = .footerTransitionFont
        addTarget(self, action: #selector(bookingButtonTapped), for: .touchUpInside)
        translatesAutoresizingMaskIntoConstraints = false
        setImage(UIImage(named: "Available-GSR"), for: .normal)
        setImage(UIImage(named: "Available-GSR-Enabled"), for: .selected)
        setImage(UIImage(named: "Available-GSR-Enabled"), for: .highlighted)
        setImage(UIImage(named: "Disabled-GSR"), for: .disabled)
        tintColor = .clear
    }
    
    private func setupIncrementLabel(_ increment: Int) {
        incrementLabel = getIncrementLabel()
        switch increment {
        case 0: incrementLabel.text = "30'"
        case 1: incrementLabel.text = "60'"
        default: incrementLabel.text = "90'"
        }
        self.addSubview(incrementLabel)
        
        incrementLabel.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
        incrementLabel.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
        incrementLabel.topAnchor.constraint(equalTo: topAnchor).isActive = true
        incrementLabel.centerXAnchor.constraint(equalTo: centerXAnchor, constant: 2).isActive = true
    }
    
    fileprivate func getIncrementLabel() -> UILabel {
        let label = UILabel()
        label.font = .gsrTimeIncrementFont
        label.textColor = .baseGreen
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
    @objc fileprivate func bookingButtonTapped() {
        if let booking = booking {
            delegate?.handleBookingSelected(booking)
        }
    }
}
