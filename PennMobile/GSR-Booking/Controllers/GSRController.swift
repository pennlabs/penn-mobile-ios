//
//  GSROverhaulController.swift
//  PennMobile
//
//  Created by Zhilei Zheng on 2/2/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//

import UIKit
import WebKit
import SCLAlertView

class GSRController: GenericViewController, IndicatorEnabled, ShowsAlert {

    // MARK: UI Elements
    fileprivate var tableView: UITableView!
    fileprivate var rangeSlider: GSRRangeSlider!
    fileprivate var datePickerView: UIStackView!
    fileprivate var closedView: GSRClosedView!
    fileprivate var barButton: UIBarButtonItem!
    fileprivate var bookingsBarButton: UIBarButtonItem!
    fileprivate var limitedAccessLabel: UILabel!

    fileprivate var todayButton: UIButton!
    fileprivate var tomorrowButton: UIButton!
    fileprivate var dateButton: UIButton!

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
//        self.pickerView.selectRow(index, inComponent: 1, animated: true)
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
            self.title = viewModel.getSelectedLocation().name
            self.navigationItem.rightBarButtonItem = barButton
        }
    }
}

// MARK: - Setup UI
extension GSRController {
    fileprivate func prepareUI() {
        prepareDatePickerView()
        prepareRangeSlider()
        prepareTableView()
        prepareClosedView()
        prepareLimitedAccessLabel()
    }

    private func prepareDatePickerView() {
        datePickerView = UIStackView()
        datePickerView.translatesAutoresizingMaskIntoConstraints = false
        datePickerView.axis = .horizontal
        datePickerView.distribution = .fillEqually
        datePickerView.alignment = .fill
        prepareDateButtons()
        view.addSubview(datePickerView)
        datePickerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        datePickerView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        datePickerView.widthAnchor.constraint(equalToConstant: view.frame.width - 2 * pad).isActive = true
    }

    func prepareDateButtons() {
        let today = Date()
        let (todayButtonView, todayButton) = makeDayButton(title: "Today", icon: today.dayInMonth + ".square.fill", buttonSelector: #selector(setToday(_:)))
        self.todayButton = todayButton
        let (tomorrowButtonView, tomorrowButton) = makeDayButton(title: "Tomorrow", icon: today.tomorrow.dayInMonth + ".square.fill", buttonSelector: #selector(setTomorrow(_:)))
        self.tomorrowButton = tomorrowButton
        let (dateButtonView, dateButton) = makeDayButton(title: "Date", icon: "calendar", buttonSelector: #selector(setToday(_:)))
        self.dateButton = dateButton
        datePickerView.addArrangedSubview(todayButtonView)
        datePickerView.addArrangedSubview(tomorrowButtonView)
        datePickerView.addArrangedSubview(dateButtonView)
    }

    func makeDayButton(title: String, icon: String, buttonSelector: Selector) -> (UIView, UIButton) {
        let dayButton = UIButton()
        dayButton.translatesAutoresizingMaskIntoConstraints = false
        dayButton.setImage(UIImage(systemName: icon), for: .normal)
        dayButton.imageView?.tintColor = .systemPink
        dayButton.addTarget(self, action: buttonSelector, for: .touchUpInside)

        let dayButtonLabel = UILabel()
        dayButtonLabel.translatesAutoresizingMaskIntoConstraints = false
        dayButtonLabel.text = title
        dayButtonLabel.textAlignment = .center

        let dayButtonWrapper = UIView()
        dayButtonWrapper.addSubview(dayButton)
        dayButtonWrapper.addSubview(dayButtonLabel)

        dayButtonWrapper.widthAnchor.constraint(equalToConstant: view.frame.width / 3).isActive = true
        dayButtonWrapper.heightAnchor.constraint(equalToConstant: view.frame.width * 7 / 24).isActive = true

        dayButtonLabel.topAnchor.constraint(equalTo: dayButton.bottomAnchor).isActive = true
        dayButtonLabel.centerXAnchor.constraint(equalTo: dayButtonWrapper.centerXAnchor).isActive = true

        dayButton.centerYAnchor.constraint(equalTo: dayButtonWrapper.centerYAnchor).isActive = true
        dayButton.centerXAnchor.constraint(equalTo: dayButtonWrapper.centerXAnchor).isActive = true

        dayButton.imageView?.translatesAutoresizingMaskIntoConstraints = false
        dayButton.imageView?.widthAnchor.constraint(equalToConstant: view.safeAreaLayoutGuide.layoutFrame.width/8).isActive = true
        dayButton.imageView?.heightAnchor.constraint(equalToConstant: view.safeAreaLayoutGuide.layoutFrame.width/8).isActive = true
        return (dayButtonWrapper, dayButton)
    }

    @objc func setToday(_ sender: UIButton?) {
        viewModel.setDate(date: Date())
        resetButtons()
    }

    @objc func setTomorrow(_ sender: UIButton?) {
        viewModel.setDate(date: Date().tomorrow)
        resetButtons()
    }

    private func prepareRangeSlider() {
        rangeSlider = GSRRangeSlider()
        rangeSlider.delegate = viewModel

        view.addSubview(rangeSlider)
        _ = rangeSlider.anchor(datePickerView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 8, leftConstant: 20, bottomConstant: 0, rightConstant: 20, widthConstant: 0, heightConstant: 30)
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
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(abbreviation: "EST")!
        formatter.dateFormat = "yyyy-MM-dd"
        let dateString = formatter.string(from: date)

        GSRNetworkManager.instance.getAvailability(lid: location.lid, gid: location.gid, startDate: dateString) { result in
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
                    if location.gid == 1 {
                        if !Account.isLoggedIn {
                            self.limitedAccessLabel.isHidden = false
                            self.tableView.isHidden = true
                            self.limitedAccessLabel.text = "You need to log in with a Wharton pennkey to access Wharton GSRs"
                            return
                        }

                        if Account.isLoggedIn && !UserDefaults.standard.isInWharton() {
                            self.limitedAccessLabel.isHidden = false
                            self.tableView.isHidden = true
                            self.limitedAccessLabel.text = "You need to have a Wharton pennkey to access Wharton GSRs"
                            return
                        }
                    }
                    self.navigationVC?.addStatusBar(text: .apiError)
                }
            }
        }
    }

    func refreshDataUI() {
        tableView.isHidden = !viewModel.existsTimeSlot()
        closedView.isHidden = viewModel.existsTimeSlot()
        self.tableView.reloadData()
    }
    // TODO: Make this boi
    func resetButtons() {
        todayButton.imageView?.tintColor = .systemPink
        tomorrowButton.imageView?.tintColor = .systemPink
        dateButton.imageView?.tintColor = .systemPink
        if (viewModel.getSelectedDate().isToday) {
            todayButton.imageView?.tintColor = .systemBlue
        } else if (viewModel.getSelectedDate().isTomorrow) {
            tomorrowButton.imageView?.tintColor = .systemBlue
        } else {
            dateButton.imageView?.tintColor = .systemBlue
        }
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
//            pickerView.reloadAllComponents()
        }
    }
}
