//
//  GSRGroupConfirmBookingController.swift
//  PennMobile
//
//  Created by Daniel Salib on 2/28/20.
//  Copyright © 2020 PennLabs. All rights reserved.
//

import UIKit

class GSRGroupConfirmBookingController: UIViewController {
    
    var groupBooking: GSRGroupBooking?
    fileprivate var viewModel: GSRGroupConfirmBookingViewModel!
    
    fileprivate var titleLabel: UILabel!
    fileprivate var groupLabel: UILabel!
    fileprivate var closeButton: UIButton!
    fileprivate var bookingsTableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        prepareViewModel()
        prepareUI()
    }
}
// MARK: - Prepare View Model
extension GSRGroupConfirmBookingController {
    func prepareViewModel() {
        guard let groupBooking = groupBooking else { return }
        viewModel = GSRGroupConfirmBookingViewModel(groupBooking: groupBooking)
    }
}

// MARK: - Prepare UI
extension GSRGroupConfirmBookingController {
    func prepareUI() {
        view.backgroundColor = UIColor.uiGSRBackground
        
        prepareTitleLabel()
        prepareGroupLabel()
        prepareCloseButton()
        prepareBookingsTableView()
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
        titleLabel.heightAnchor.constraint(equalToConstant: 29).isActive = true
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func prepareGroupLabel() {
        groupLabel = UILabel()
        if let group = groupBooking?.group {
            groupLabel.attributedText = NSMutableAttributedString().weightedColored("Booking as ", weight: .light, color: .grey1, size: 18).weightedColored(group.name, weight: .bold, color: group.color, size: 18)
        }
        
        view.addSubview(groupLabel)
        groupLabel.translatesAutoresizingMaskIntoConstraints = false
        groupLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8).isActive = true
        groupLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor).isActive = true
        groupLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor).isActive = true
        groupLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true
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
        closeButton.setTitle("X", for: .normal)
        closeButton.setTitleColor(UIColor.grey1, for: .normal)
        closeButton.addTarget(self, action: #selector(cancelBtnAction), for: .touchUpInside)
    }
    
    func prepareBookingsTableView() {
        bookingsTableView = UITableView()
        bookingsTableView.delegate = viewModel
        bookingsTableView.dataSource = viewModel
        bookingsTableView.separatorStyle = .none
        bookingsTableView.register(GroupBookingConfirmationCell.self, forCellReuseIdentifier:   GroupBookingConfirmationCell.identifier)
        bookingsTableView.allowsSelection = false
        bookingsTableView.rowHeight = UITableView.automaticDimension
        bookingsTableView.estimatedRowHeight = 300.0
        bookingsTableView.backgroundColor = UIColor.clear
        view.addSubview(bookingsTableView)
        
        _ = bookingsTableView.anchor(groupLabel.bottomAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, topConstant: 30.0, leftConstant: 14.0, bottomConstant: 100.0, rightConstant: 14.0, widthConstant: 0.0, heightConstant: 0.0)
    }
}

// MARK: - Handle Cancel
extension GSRGroupConfirmBookingController {
    @objc func cancelBtnAction() {
        self.dismiss(animated: true, completion: nil)
    }
}
