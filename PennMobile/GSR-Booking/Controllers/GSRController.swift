//
//  GSROverhaulController.swift
//  PennMobile
//
//  Created by Zhilei Zheng on 2/2/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//

import UIKit
import WebKit

class GSRController: GenericViewController, IndicatorEnabled {

    // MARK: UI Elements
    fileprivate var tableView: UITableView!
    fileprivate var rangeSlider: GSRRangeSlider!
    fileprivate var pickerView: UIPickerView!
    fileprivate var emptyView: EmptyView!
    fileprivate var barButton: UIBarButtonItem!
    fileprivate var bookingsBarButton: UIBarButtonItem!
    
    var group: GSRGroup?
    
    var barButtonTitle = "Submit"
    
    var currentDay = Date()

    fileprivate var viewModel: GSRViewModel!
    
    var loadingView: UIActivityIndicatorView!

    var startingLocation: GSRLocation!

    override func viewDidLoad() {
        super.viewDidLoad()
        prepareViewModel()
        prepareUI()
        
        let index = viewModel.getLocationIndex(startingLocation)
        self.pickerView.selectRow(index, inComponent: 1, animated: true)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateForNewDayIfNeeded()
        rangeSlider?.reload()
        fetchData()
    }

    override func setupNavBar() {
        if group != nil {
            barButtonTitle = "Review"
        }
        
        barButton = UIBarButtonItem(title: barButtonTitle, style: .done, target: self, action: #selector(handleBarButtonPressed(_:)))
        barButton.tintColor = UIColor.navigation

        bookingsBarButton = UIBarButtonItem(title: "Bookings", style: .done, target: self, action: #selector(handleBookingsBarButtonPressed(_:)))
        bookingsBarButton.tintColor = UIColor.navigation
        
        if let tabBarController = tabBarController {
            tabBarController.title = "Study Room Booking"
            tabBarController.navigationItem.leftBarButtonItem = bookingsBarButton
            tabBarController.navigationItem.rightBarButtonItem = barButton
        } else {
            self.title = "Tap to book"
            self.navigationItem.rightBarButtonItem = barButton
        }
    }
}

// MARK: - Setup UI
extension GSRController {
    fileprivate func prepareUI() {
        preparePickerView()
        prepareRangeSlider()
        prepareTableView()
        prepareEmptyView()
        prepareLoadingView()
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
}

// MARK: - Prepare View Model
extension GSRController {
    fileprivate func prepareViewModel() {
        viewModel = GSRViewModel(selectedLocation: startingLocation)
        viewModel.delegate = self
        viewModel.group = group
    }
}

// MARK: - ViewModelDelegate + Networking
extension GSRController: GSRViewModelDelegate {
    func fetchData() {
        let location = viewModel.getSelectedLocation()
        let date = viewModel.getSelectedDate()
        
        self.startLoadingViewAnimation()
        
        GSRNetworkManager.instance.getAvailability(for: location.lid, date: date) { (rooms) in
            
            DispatchQueue.main.async {
                if let rooms = rooms {
                    self.viewModel.updateData(with: rooms)
                    self.refreshDataUI()
                    self.rangeSlider.reload()
                    self.refreshBarButton()
                    self.stopLoadingViewAnimation()
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
extension GSRController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view == rangeSlider || touch.location(in: tableView).y > 0 {
            return false
        }
        return true
    }
}

// MARK: - Activity Indicator
extension GSRController {
    func prepareLoadingView() {
        loadingView = UIActivityIndicatorView(style: .whiteLarge)
        loadingView.color = .black
        loadingView.isHidden = false
        view.addSubview(loadingView)
        loadingView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loadingView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        loadingView.translatesAutoresizingMaskIntoConstraints = false
    }

    func startLoadingViewAnimation() {
        if loadingView != nil && !loadingView.isHidden {
            loadingView.startAnimating()
        }
    }

    func stopLoadingViewAnimation() {
        self.loadingView.isHidden = true
        self.loadingView.stopAnimating()
    }
}
// MARK: - Bar Button Refresh + Handler
extension GSRController: GSRBookable {
    fileprivate func refreshBarButton() {
        self.barButton.tintColor = .clear
        self.barButton.tintColor = nil
    }

    @objc fileprivate func handleBarButtonPressed(_ sender: Any) {
        if let booking = viewModel.getBooking() {
            submitPressed(for: booking)
        } else {
            // Alert. Nothing selected.
            showAlert(withMsg: "Please select a timeslot to book.", title: "Empty Selection", completion: nil)
        }
    }

    @objc fileprivate func handleBookingsBarButtonPressed(_ sender: Any) {
        let grc = GSRReservationsController()
        self.navigationController?.pushViewController(grc, animated: true)
    }
    
    private func presentWebviewLoginController(_ completion: (() -> Void)? = nil) {
        let wv = GSRWebviewLoginController()
        wv.completion = completion
        let nvc = UINavigationController(rootViewController: wv)
        present(nvc, animated: true, completion: nil)
    }

    private func presentLoginController(with booking: GSRBooking? = nil) {
        let glc = GSRLoginController()
        glc.booking = booking
        let nvc = UINavigationController(rootViewController: glc)
        present(nvc, animated: true, completion: nil)
    }

    private func submitPressed(for booking: GSRBooking) {
        if let booking = booking as? GSRGroupBooking {
            handleGroupBooking(booking)
            return
        }
        
        if GSRNetworkManager.instance.bookingRequestOutstanding {
            return
        }

        let location = viewModel.getSelectedLocation()
        if location.service == "wharton" {
            if let sessionId = GSRUser.getSessionID() {
                booking.sessionId = sessionId
                submitBooking(for: booking) { (success) in
                    if success {
                        self.fetchData()
                    } else {
                        self.viewModel.clearSelection()
                        self.refreshDataUI()
                    }
                }
            } else {
                presentWebviewLoginController {
                    if let sessionId = GSRUser.getSessionID() {
                        booking.sessionId = sessionId
                        self.submitBooking(for: booking) { (success) in
                            self.fetchData()
                        }
                    }
                }
            }
        } else {
            if let user = GSRUser.getUser() {
                booking.user = user
                submitBooking(for: booking) { (success) in
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
}

extension GSRController {
    private func handleGroupBooking(_ booking: GSRGroupBooking) {
        let confirmController = GSRGroupConfirmBookingController()
        confirmController.group = booking.gsrGroup
        confirmController.booking = booking
        present(confirmController, animated: true, completion: nil)
    }
}

// MARK: - Update For New Day
extension GSRController {
    func updateForNewDayIfNeeded() {
        if !currentDay.isToday {
            currentDay = Date()
            viewModel.updateDates()
            pickerView.reloadAllComponents()
        }
    }
}
