//
//  GSROverhaulController.swift
//  PennMobile
//
//  Created by Zhilei Zheng on 2/2/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//

import UIKit
import WebKit

class GSRController: GenericViewController, IndicatorEnabled, ShowsAlert {

    // MARK: UI Elements
    fileprivate var tableView: UITableView!
    fileprivate var rangeSlider: GSRRangeSlider!
    fileprivate var pickerView: UIPickerView!
    fileprivate var closedView: GSRClosedView!
    fileprivate var barButton: UIBarButtonItem!
    fileprivate var bookingsBarButton: UIBarButtonItem!
    fileprivate var limitedAccessLabel: UILabel!

    var group: GSRGroup?

    var barButtonTitle = "Submit"

    var currentDay = Date()

    fileprivate var viewModel: GSRViewModel!

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
        prepareClosedView()
        prepareLimitedAccessLabel()
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

    private func prepareClosedView() {
        closedView = GSRClosedView()
        closedView.isHidden = true

        view.addSubview(closedView)
        _ = closedView.anchor(tableView.topAnchor, left: tableView.leftAnchor, bottom: tableView.bottomAnchor, right: tableView.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
    }

    private func prepareLimitedAccessLabel() {
        limitedAccessLabel = UILabel()
        limitedAccessLabel.isHidden = true
        limitedAccessLabel.numberOfLines = 0
        limitedAccessLabel.textAlignment = .center

        view.addSubview(limitedAccessLabel)
        limitedAccessLabel.translatesAutoresizingMaskIntoConstraints = false
        limitedAccessLabel.topAnchor.constraint(equalTo: rangeSlider.topAnchor, constant: Padding.pad).isActive = true
        limitedAccessLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: Padding.pad).isActive = true
        limitedAccessLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -Padding.pad).isActive = true
        limitedAccessLabel.heightAnchor.constraint(equalToConstant: 200).isActive = true
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
    func resetDataForCell(at indexPath: IndexPath) {
        (tableView.cellForRow(at: indexPath) as? RoomCell)?.resetSelection()
    }

    func fetchData() {
        let location = viewModel.getSelectedLocation()
        let date = viewModel.getSelectedDate()
        self.showActivity()

        if !Account.isLoggedIn {
            self.showAlert(withMsg: "You are not logged in!", title: "Error", completion: {self.navigationController?.popViewController(animated: true)})
        } else if location.kind == .wharton && !UserDefaults.standard.isInWharton() {
            self.showAlert(withMsg: "You need to have a Wharton pennkey to access Wharton GSRs", title: "Error", completion: { self.navigationController?.popViewController(animated: true)
            })
        } else {
            GSRNetworkManager.instance.getAvailability(lid: location.lid, gid: location.gid, startDate: date.string) { result in
                DispatchQueue.main.async {
                    self.limitedAccessLabel.isHidden = true
                    self.tableView.isHidden = false
                    self.hideActivity()
                    switch result {
                    case .success(let rooms):
                        self.viewModel.updateData(with: rooms)
                        self.refreshDataUI()
                        self.rangeSlider.reload()
                        self.refreshBarButton()
                    case .failure:
                        self.navigationVC?.addStatusBar(text: .apiError)
                    }
                }
            }
        }
    }

    func refreshDataUI() {
        tableView.isHidden = !viewModel.existsTimeSlot()
        closedView.isHidden = viewModel.existsTimeSlot()
        self.tableView.reloadData()
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

// MARK: - Bar Button Refresh + Handler
extension GSRController: GSRBookable {
    fileprivate func refreshBarButton() {
        self.barButton.tintColor = .clear
        self.barButton.tintColor = nil
    }

    @objc fileprivate func handleBarButtonPressed(_ sender: Any) {
        if let id = viewModel.getSelectedRoomId(), let roomIndexPath = viewModel.getSelectedRoomIdIndexPath() {
            let gid = viewModel.getSelectedLocation().gid
            let roomName = viewModel.getSelectRoomName() ?? ""
            let times = (tableView.cellForRow(at: roomIndexPath) as? RoomCell)?.getSelectTimes() ?? []

            if times.count == 0 {
                showAlert(withMsg: "Please select a timeslot to book.", title: "Empty Selection", completion: nil)
            }

            let sorted = times.sorted(by: {$0.startTime < $1.startTime})

            let first = sorted.first!
            let last = sorted.last!

            // wharton prevents booking more than 90 minutes
            if gid == 1 && times.count > 3 {
                showAlert(withMsg: "You cannot book for more than 90 minutes for Wharton GSRs", title: "Invalid Selection", completion: nil)
            } else if times.count > 4 {
                showAlert(withMsg: "You cannot book for more than 120 minutes for Library GSRs", title: "Invalid Selection", completion: nil)
            } else {
                if Account.isLoggedIn {
                    submitBooking(for: GSRBooking(gid: gid, startTime: first.startTime, endTime: last.endTime, id: id, roomName: roomName))
                } else {
                    let alertController = UIAlertController(title: "Login Error", message: "Please login to book GSRs", preferredStyle: .alert)

                    alertController.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: {_ in }))
                    alertController.addAction(UIAlertAction(title: "Login", style: .default, handler: { _ in
                        let llc = LabsLoginController { (_) in
                            DispatchQueue.main.async {
                                self.submitBooking(for: GSRBooking(gid: gid, startTime: first.startTime, endTime: last.endTime, id: id, roomName: roomName))
                            }
                        }

                        let nvc = UINavigationController(rootViewController: llc)

                        self.present(nvc, animated: true, completion: nil)
                    }))

                    present(alertController, animated: true, completion: nil)
                }
            }
        } else {
            showAlert(withMsg: "Please select a timeslot to book.", title: "Empty Selection", completion: nil)
        }
    }

    func getBooking() -> GSRBooking? {
        if let id = viewModel.getSelectedRoomId(), let roomIndexPath = viewModel.getSelectedRoomIdIndexPath() {
            let gid = viewModel.getSelectedLocation().gid
            let roomName = viewModel.getSelectRoomName() ?? ""
            let times = (tableView.cellForRow(at: roomIndexPath) as? RoomCell)?.getSelectTimes() ?? []

            if times.count == 0 {
                return nil
            }

            let first = times.first!
            let last = times.last!

            // wharton prevents booking more than 90 minutes
            if gid == 1 && times.count > 3 {
                showAlert(withMsg: "You cannot book for more than 90 minutes for Wharton GSRs", title: "Invalid Selection", completion: nil)
                return nil
            } else if times.count > 4 {
                showAlert(withMsg: "You cannot book for more than 120 minutes for Library GSRs", title: "Invalid Selection", completion: nil)
                return nil
            }

            return GSRBooking(gid: gid, startTime: first.startTime, endTime: last.endTime, id: id, roomName: roomName)
        }

        return nil
    }

    @objc fileprivate func handleBookingsBarButtonPressed(_ sender: Any) {
        let grc = GSRReservationsController()
        self.navigationController?.pushViewController(grc, animated: true)
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
