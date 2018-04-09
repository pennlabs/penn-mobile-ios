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
        }
    }
    var delegate : HomeGSRBookingButtonDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
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
    
    @objc fileprivate func bookingButtonTapped() {
        if let booking = booking {
            delegate?.handleBookingSelected(booking)
        }
    }
}
