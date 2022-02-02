////
////  FlingViewController.swift
////  PennMobile
////
////  Created by Josh Doman on 3/10/18.
////  Copyright © 2018 PennLabs. All rights reserved.
////
//
//import Foundation
//import ZoomImageView
//import SafariServices
//
//protocol FlingCellDelegate: ModularTableViewCellDelegate, URLSelectable {}
//
//final class FlingTableViewModel: ModularTableViewModel {}
//
//final class FlingViewController: GenericViewController, HairlineRemovable, IndicatorEnabled {
//
//    fileprivate var performersTableView: ModularTableView!
//    fileprivate var scheduleTableView: UITableView!
//    fileprivate var model: FlingTableViewModel!
//    fileprivate var headerToolbar: UIToolbar!
//
//    // TEMP COLORS - TO be deleted in favor of General/Extensions
//    fileprivate static var navigation = UIColor(r: 74, g: 144, b: 226)
//    fileprivate static var baseGreen = UIColor(r: 118, g: 191, b: 150)
//    fileprivate static var yellowLight = UIColor(r: 240, g: 180, b: 0)
//
//    // For Map Zoom
//    fileprivate var mapImageView: ZoomImageView!
//
//    fileprivate var performers = [FlingPerformer]()
//
//    fileprivate var checkInWebview: SFSafariViewController!
//    fileprivate var checkInUrl = "https://docs.google.com/forms/d/e/1FAIpQLSexkehYfGgyAa7RagaCl8rze4KUKQSX9TbcvvA6iXp34TyHew/viewform"
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        self.title = "Spring Fling"
//
//        setupThisNavBar()
//        prepareScheduleTableView()
//        preparePerformersTableView()
//        prepareMapImageView()
//        prepareCheckInButton()
//
//        performersTableView.isHidden = false
//        scheduleTableView.isHidden = true
//        mapImageView.isHidden = true
//
//        self.showActivity()
//        self.fetchViewModel {
//            // TODO: do something when fetch has completed
//            self.hideActivity()
//        }
//
//        FirebaseAnalyticsManager.shared.trackEvent(action: "Viewed Fling", result: "Viewed Fling", content: "Fling page")
//    }
//
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        if let navbar = navigationController?.navigationBar {
//            removeHairline(from: navbar)
//        }
//    }
//
//    func setupThisNavBar() {
//        //removes hairline from bottom of navbar
//        if let navbar = navigationController?.navigationBar {
//            removeHairline(from: navbar)
//        }
//
//        let width = view.frame.width
//
//        guard let headerFrame = navigationController?.navigationBar.frame else {
//            return
//        }
//
//        headerToolbar = UIToolbar(frame: CGRect(x: 0, y: 64, width: width, height: headerFrame.height + headerFrame.origin.y))
//        headerToolbar.backgroundColor = navigationController?.navigationBar.backgroundColor
//
//        let newsSwitcher = UISegmentedControl(items: ["Performers", "Schedule", "Map"])
//        newsSwitcher.center = CGPoint(x: width/2, y: 64 + headerToolbar.frame.size.height/2)
//        newsSwitcher.tintColor = UIColor.navigation
//        newsSwitcher.selectedSegmentIndex = 0
//        newsSwitcher.isUserInteractionEnabled = true
//        newsSwitcher.addTarget(self, action: #selector(switchTabMode(_:)), for: .valueChanged)
//
//        view.addSubview(headerToolbar)
//        view.addSubview(newsSwitcher)
//    }
//
//    @objc internal func switchTabMode(_ segment: UISegmentedControl) {
//        performersTableView.isHidden = segment.selectedSegmentIndex == 0 ? false : true
//        scheduleTableView.isHidden = segment.selectedSegmentIndex == 1 ? false : true
//        mapImageView.isHidden = segment.selectedSegmentIndex == 2 ? false : true
//    }
//}
//
//extension FlingViewController: UITableViewDelegate, UITableViewDataSource {
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return performers.count
//    }
//
//    func numberOfSections(in tableView: UITableView) -> Int {
//        return 1
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "TimelineTableViewCell",
//                                                 for: indexPath) as! TimelineTableViewCell
//
//        cell.backgroundColor = .white
//
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "h:mm"
//        let dateFormatterTwelveHour = DateFormatter()
//        dateFormatterTwelveHour.dateFormat = "h:mm a"
//
//        var (title, description) = ("", "")
//        var (startTime, endTime) : (Date?, Date?)
//
//        let performer = performers[indexPath.row]
//        (title, description, startTime, endTime) = (performer.name,
//                                                        "\(dateFormatter.string(from: performer.startTime)) - \(dateFormatterTwelveHour.string(from: performer.endTime))",
//                                                        performer.startTime, performer.endTime)
//
//
//        if (indexPath.row > 0) {
//            cell.timeline.frontColor = .lightGray
//        } else {
//            cell.timeline.frontColor = .clear
//        }
//
//        if (startTime != nil && endTime != nil && startTime! < Date() && endTime! > Date()) {
//            cell.timeline.backColor = FlingViewController.yellowLight
//            cell.bubbleColor = FlingViewController.yellowLight
//            cell.timelinePoint = TimelinePoint(color: FlingViewController.yellowLight, filled: true)
//        } else {
//            cell.timeline.backColor = .lightGray
//            cell.bubbleColor = FlingViewController.baseGreen
//            cell.timelinePoint = TimelinePoint(color: .lightGray, filled: true)
//        }
//
//        cell.titleLabel.text = title
//        cell.descriptionLabel.text = description
//        cell.descriptionLabel.font = UIFont(name: "AvenirNext-Regular", size: 16)
//        cell.descriptionLabel.textColor = UIColor(r: 63, g: 63, b: 63)
//
//        //cell.lineInfoLabel.text = lineInfo
//        /*if indexPath.row != 5 {
//            cell.bubbleColor = FlingViewController.baseGreen
//        } else {
//            cell.bubbleColor = FlingViewController.yellowLight
//        }
//        if let thumbnail = thumbnail {
//            cell.thumbnailImageView.image = UIImage(named: thumbnail)
//        }
//        else {
//            cell.thumbnailImageView.image = nil
//        }
//        if let illustration = illustration {
//            cell.illustrationImageView.image = UIImage(named: illustration)
//        }
//        else {
//            cell.illustrationImageView.image = nil
//        }*/
//
//        return cell
//    }
//
//    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        return "Saturday, April 13th"
//    }
//
//    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return 50
//    }
//
//    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
//        if let view = view as? UITableViewHeaderFooterView {
//            // Customize header view
//            view.textLabel?.font = UIFont(name: "AvenirNext-DemiBold", size: 24)
//            view.textLabel?.textColor = UIColor(r: 63, g: 63, b: 63)
//            view.textLabel?.widthAnchor.constraint(equalToConstant: 300)
//            view.contentView.backgroundColor = UIColor.clear
//
//            // Add divider line to header view
//            let dividerLine = UIView()
//            dividerLine.backgroundColor = .lightGray
//            view.addSubview(dividerLine)
//            dividerLine.translatesAutoresizingMaskIntoConstraints = false
//            dividerLine.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
//            dividerLine.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
//            dividerLine.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
//            dividerLine.heightAnchor.constraint(equalToConstant: 1).isActive = true
//        }
//    }
//
//}
//
//// MARK: - Networking
//extension FlingViewController {
//    func fetchViewModel(_ completion: @escaping () -> Void) {
//        FlingNetworkManager.instance.fetchModel { (model) in
//            guard let model = model else { return }
//            if let prevItems = self.model?.items as? [HomeFlingCellItem], let items = model.items as? [HomeFlingCellItem], prevItems.equals(items) { return }
//            DispatchQueue.main.async {
//                self.setPerformersTableViewModel(model)
//                self.performersTableView.reloadData()
//                self.setScheduleTableViewModel(model)
//                self.scheduleTableView.reloadData()
//                self.fetchCellSpecificData {
//                    // TODO: do something when done fetching cell specific data
//                }
//                completion()
//            }
//        }
//    }
//
//    func fetchCellSpecificData(_ completion: (() -> Void)? = nil) {
//        guard let items = model.items as? [HomeCellItem] else { return }
//        HomeAsynchronousAPIFetching.instance.fetchData(for: items, singleCompletion: { (item) in
//            DispatchQueue.main.async {
//                let row = items.firstIndex(where: { (thisItem) -> Bool in
//                    thisItem.equals(item: item)
//                })!
//                let indexPath = IndexPath(row: row, section: 0)
//                self.performersTableView.reloadRows(at: [indexPath], with: .none)
//            }
//        }) {
//            DispatchQueue.main.async {
//                completion?()
//            }
//        }
//    }
//
//
//    func setPerformersTableViewModel(_ model: FlingTableViewModel) {
//        self.model = model
//        self.model.delegate = self
//        performersTableView.model = self.model
//    }
//
//    func setScheduleTableViewModel(_ model: FlingTableViewModel) {
//        performers = model.items.map { (item) -> FlingPerformer in
//            let flingItem = item as! HomeFlingCellItem
//            return flingItem.performer
//        }
//        performers.sort(by: { ($0.startTime < $1.startTime) })
//    }
//}
//
//// MARK: - ModularTableViewDelegate
//extension FlingViewController: FlingCellDelegate {
//    func handleUrlPressed(urlStr: String, title: String, item: ModularTableViewItem, shouldLog: Bool) {
//        checkInWebview = SFSafariViewController(url: URL(string: checkInUrl)!)
//        navigationController?.present(checkInWebview, animated: true)
//        FirebaseAnalyticsManager.shared.trackEvent(action: "Fling Check-In", result: "Fling Check-In", content: "Fling Check-In")
//    }
//}
//
//// MARK: - Check In
//extension FlingViewController {
//    fileprivate func prepareCheckInButton() {
//        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Check-In", style: .done, target: self, action: #selector(handleCheckInButtonPressed(_:)))
//    }
//
//    @objc fileprivate func handleCheckInButtonPressed(_ sender: Any?) {
//        checkInWebview = SFSafariViewController(url: URL(string: checkInUrl)!)
//        navigationController?.present(checkInWebview, animated: true)
//    }
//}
//
//// MARK: - Map Image
//extension FlingViewController {
//    fileprivate func prepareMapImageView() {
//        mapImageView = ZoomImageView()
//        mapImageView.image = UIImage(named: "Fling_Map")
//
//        view.addSubview(mapImageView)
//
//        mapImageView.anchorToTop(nil, left: view.leftAnchor, bottom: nil, right: view.rightAnchor)
//        mapImageView.topAnchor.constraint(equalTo: headerToolbar.bottomAnchor, constant: 0).isActive = true
//        mapImageView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0).isActive = true
//    }
//}
//
//// MARK: - Prepare TableViews
//extension FlingViewController {
//    func prepareScheduleTableView() {
//        scheduleTableView = UITableView()
//        scheduleTableView.backgroundColor = .uiBackground
//        scheduleTableView.separatorStyle = .none
//        scheduleTableView.allowsSelection = false
//        scheduleTableView.showsVerticalScrollIndicator = false
//
//        // Initialize TimelineTableViewCell
//        let bundle = Bundle(for: TimelineTableViewCell.self)
//        let nibUrl = bundle.url(forResource: "TimelineTableViewCell", withExtension: "bundle")
//        let timelineTableViewCellNib = UINib(nibName: "TimelineTableViewCell", bundle: Bundle(url: nibUrl!)!)
//        scheduleTableView.register(timelineTableViewCellNib, forCellReuseIdentifier: "TimelineTableViewCell")
//
//        scheduleTableView.delegate = self
//        scheduleTableView.dataSource = self
//
//        view.addSubview(scheduleTableView)
//
//        scheduleTableView.anchorToTop(nil, left: view.leftAnchor, bottom: nil, right: view.rightAnchor)
//        if #available(iOS 11.0, *) {
//            scheduleTableView.topAnchor.constraint(equalTo: headerToolbar.bottomAnchor, constant: 0).isActive = true
//            scheduleTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0).isActive = true
//        } else {
//            scheduleTableView.topAnchor.constraint(equalTo: headerToolbar.bottomAnchor, constant: 0).isActive = true
//            scheduleTableView.bottomAnchor.constraint(equalTo: bottomLayoutGuide.bottomAnchor, constant: 0).isActive = true
//        }
//    }
//
//    func preparePerformersTableView() {
//        performersTableView = ModularTableView()
//        performersTableView.backgroundColor = .clear
//        performersTableView.separatorStyle = .none
//
//        view.addSubview(performersTableView)
//
//        performersTableView.anchorToTop(nil, left: view.leftAnchor, bottom: nil, right: view.rightAnchor)
//        if #available(iOS 11.0, *) {
//            performersTableView.topAnchor.constraint(equalTo: headerToolbar.bottomAnchor, constant: 0).isActive = true
//            performersTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0).isActive = true
//        } else {
//            performersTableView.topAnchor.constraint(equalTo: headerToolbar.bottomAnchor, constant: 0).isActive = true
//            performersTableView.bottomAnchor.constraint(equalTo: bottomLayoutGuide.bottomAnchor, constant: 0).isActive = true
//        }
//
//        performersTableView.tableFooterView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: self.view.frame.width, height: 30.0))
//
//        HomeItemTypes.instance.registerCells(for: performersTableView)
//    }
//}
//
//
//
//
//
//
