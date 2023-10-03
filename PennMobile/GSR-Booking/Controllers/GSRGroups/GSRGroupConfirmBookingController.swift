//
//  GSRGroupConfirmBookingController.swift
//  PennMobile
//
//  Created by Daniel Salib on 2/28/20.
//  Copyright © 2020 PennLabs. All rights reserved.
//

import UIKit
import PennMobileShared

class GSRGroupConfirmBookingController: UIViewController {

    var group: GSRGroup!
//    var booking: GSRGroupBooking!

    fileprivate var titleLabel: UILabel!
    fileprivate var groupLabel: UILabel!
    fileprivate var closeButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        prepareUI()
    }
}

extension GSRGroupConfirmBookingController {
    func prepareUI() {
        view.backgroundColor = UIColor.uiBackground
        prepareTitleLabel()
        prepareGroupLabel()
        prepareCloseButton()
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

    func prepareGroupLabel() {
        groupLabel = UILabel()
        groupLabel.attributedText = NSMutableAttributedString().weightedColored("Booking as ", weight: .light, color: .grey1, size: 18).weightedColored(group.name, weight: .bold, color: group.color, size: 18)

        view.addSubview(groupLabel)
        groupLabel.translatesAutoresizingMaskIntoConstraints = false
        groupLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8).isActive = true
        groupLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor).isActive = true

    }

    func prepareCloseButton() {
        closeButton = UIButton()
        view.addSubview(closeButton)

        closeButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 32).isActive = true
        closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16).isActive = true
        closeButton.backgroundColor = UIColor(red: 118/255, green: 118/255, blue: 128/255, alpha: 12/100)
        closeButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        closeButton.widthAnchor.constraint(equalToConstant: 30).isActive = true
        closeButton.layer.cornerRadius = 15
        closeButton.layer.masksToBounds = false
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.setTitle("X", for: UIControl.State.normal)
        closeButton.addTarget(self, action: #selector(cancelBtnAction), for: .touchUpInside)
    }
}

extension GSRGroupConfirmBookingController {
    @objc func cancelBtnAction() {
        self.dismiss(animated: true, completion: nil)
    }
}
