//
//  GSROverhaulController.swift
//  PennMobile
//
//  Created by Zhilei Zheng on 2/2/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//

import UIKit
import SCLAlertView

class GSROverhaulController: GenericViewController, IndicatorEnabled {
    
    // MARK: UI Elements
    fileprivate var tableView: UITableView!
    fileprivate var rangeSlider: GSRRangeSlider!
    fileprivate var pickerView: UIPickerView!
    fileprivate var emptyView: EmptyView!
    fileprivate var barButton: UIBarButtonItem!
    
    var barButtonTitle: String {
        get {
            switch viewModel.state {
            case .loggedIn:
                return "Logout"
            case .loggedOut:
                return "Login"
            case .readyToSubmit:
                return "Submit"
            }
        }
    }
    
    fileprivate var viewModel: GSRViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Study Room Booking"
        
        prepareViewModel()
        prepareUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        rangeSlider?.reload()
        refreshBarButton()
        revealViewController().panGestureRecognizer().delegate = self
        fetchData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        revealViewController().panGestureRecognizer().delegate = nil
    }
}

// MARK: - Setup UI
extension GSROverhaulController {
    fileprivate func prepareUI() {
        preparePickerView()
        prepareRangeSlider()
        prepareTableView()
        prepareEmptyView()
        prepareBarButton()
    }
    
    private func preparePickerView() {
        pickerView = UIPickerView(frame: .zero)
        pickerView.translatesAutoresizingMaskIntoConstraints = false
        pickerView.delegate = viewModel
        pickerView.dataSource = viewModel
        
        view.addSubview(pickerView)
        pickerView.topAnchor.constraint(equalTo: view.topAnchor, constant: 60).isActive = true
        pickerView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
    
    private func prepareRangeSlider() {
        rangeSlider = GSRRangeSlider()
        rangeSlider.delegate = viewModel
        
        view.addSubview(rangeSlider)
        _ = rangeSlider.anchor(pickerView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 8, leftConstant: 20, bottomConstant: 0, rightConstant: 20, widthConstant: 0, heightConstant: 30)
    }
    
    private func prepareTableView() {
        tableView = UITableView(frame: .zero)
        tableView.dataSource = viewModel
        tableView.delegate = viewModel
        tableView.register(RoomCell.self, forCellReuseIdentifier: RoomCell.identifier)
        tableView.tableFooterView = UIView()
        
        view.addSubview(tableView)
        _ = tableView.anchor(rangeSlider.bottomAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, topConstant: 8, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
    }
    
    private func prepareEmptyView() {
        emptyView = EmptyView()
        emptyView.isHidden = true
        
        view.addSubview(emptyView)
        _ = emptyView.anchor(tableView.topAnchor, left: tableView.leftAnchor, bottom: tableView.bottomAnchor, right: tableView.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
    }
    
    private func prepareBarButton() {
        barButton = UIBarButtonItem(title: barButtonTitle, style: .done, target: self, action: #selector(handleBarButtonPressed(_:)))
        navigationItem.rightBarButtonItem = barButton
    }
}

// MARK: - Prepare View Model
extension GSROverhaulController {
    fileprivate func prepareViewModel() {
        viewModel = GSRViewModel()
        viewModel.delegate = self
    }
}

// MARK: - ViewModelDelegate + Networking
extension GSROverhaulController: GSRViewModelDelegate {
    func fetchData() {
        let locationId = viewModel.getSelectedLocation().id
        let date = viewModel.getSelectedDate()
        GSROverhaulManager.instance.getAvailability(for: locationId, date: date) { (rooms) in
            DispatchQueue.main.async {
                if let rooms = rooms {
                    self.viewModel.updateData(with: rooms)
                    self.refreshDataUI()
                    self.rangeSlider.reload()
                    self.refreshBarButton()
                }
            }
        }
    }
    
    func refreshDataUI() {
        emptyView.isHidden = !viewModel.isEmpty
        tableView.isHidden = viewModel.isEmpty
        self.tableView.reloadData()
    }
    
    func refreshSelectionUI() {
        self.refreshBarButton()
    }
}

// MARK: - UIGestureRecognizerDelegate
extension GSROverhaulController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view == rangeSlider || touch.location(in: tableView).y > 0 {
            return false
        }
        return true
    }
}

// MARK: - Bar Button Refresh + Handler
extension GSROverhaulController: GSRBookable {
    fileprivate func refreshBarButton() {
        self.barButton.tintColor = .clear
        barButton.title = barButtonTitle
        self.barButton.tintColor = nil
    }
    
    @objc fileprivate func handleBarButtonPressed(_ sender: Any) {
        switch viewModel.state {
        case .loggedOut:
            presentLoginController()
            break
        case .loggedIn:
            GSRUser.clear()
            refreshBarButton()
            break
        case .readyToSubmit(let booking):
            submitPressed(for: booking)
            break
        }
    }
    
    private func presentLoginController(with booking: GSRBooking? = nil) {
        let glc = GSRLoginController()
        glc.booking = booking
        let nvc = UINavigationController(rootViewController: glc)
        present(nvc, animated: true, completion: nil)
    }
    
    private func submitPressed(for booking: GSRBooking) {
        if let user = GSRUser.getUser() {
            booking.user = user
            let failureMessage = "It seems like your request failed. Please update your contact information and try again."
            submitBooking(for: booking, failureMessage: failureMessage) { (success) in
                if success {
                    self.fetchData()
                } else {
                    self.presentLoginController(with: booking)
                }
            }
        } else {
            presentLoginController(with: booking)
        }
    }
}

protocol GSRBookable: IndicatorEnabled {}

extension GSRBookable where Self: UIViewController {
    func submitBooking(for booking: GSRBooking, failureMessage: String,
                       _ completion: @escaping (_ success: Bool) -> Void) {
        self.showActivity()
        GSROverhaulManager.instance.makeBooking(for: booking) { (success) in
            DispatchQueue.main.async {
                self.hideActivity()
                let alertView = SCLAlertView()
                if success {
                    alertView.showSuccess("Success!", subTitle: "You should receive a confirmation email in the next few minutes.")
                } else {
                    alertView.showError("Uh oh!", subTitle: failureMessage)
                }
                completion(success)
            }
        }
    }
}
