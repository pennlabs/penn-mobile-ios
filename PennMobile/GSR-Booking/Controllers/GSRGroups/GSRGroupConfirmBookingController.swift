//
//  GSRGroupConfirmBookingController.swift
//  PennMobile
//
//  Created by Daniel Salib on 2/28/20.
//  Copyright © 2020 PennLabs. All rights reserved.
//

import UIKit

class GSRGroupConfirmBookingController: UIViewController {
    
    var group: GSRGroup!
    fileprivate var titleLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        prepareUI()
    }
}

extension GSRGroupConfirmBookingController {
    func prepareUI() {
        view.backgroundColor = UIColor.uiBackground
        prepareTitleLabel()
    }
    
    func prepareTitleLabel() {
        titleLabel = UILabel()
        titleLabel.text = "Confirm Booking"
        titleLabel.font = .boldSystemFont(ofSize: 28)
        titleLabel.textColor = .baseDarkBlue
        
        view.addSubview(titleLabel)
        titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 32).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 14).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -14).isActive = true
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
    }
}
