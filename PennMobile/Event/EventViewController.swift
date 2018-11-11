//
//  EventViewController.swift
//  PennMobile
//
//  Created by Carin Gan on 11/4/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//

import Foundation
import SimpleImageViewer
import TimelineTableViewCell

protocol EventCellDelegate: ModularTableViewCellDelegate, URLSelectable {}

final class EventTableViewModel: ModularTableViewModel {}

final class EventViewController: GenericViewController {
    
    fileprivate var eventsTableView: ModularTableView!
    fileprivate var scheduleTableView: UITableView!
    fileprivate var model: EventTableViewModel!
    fileprivate var headerToolbar: UIToolbar!
    
    fileprivate var events = [Event]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Event"
        
        setupNavBar()
        prepareScheduleTableView()
        prepareEventsTableView()
        
        scheduleTableView.isHidden = true
        eventsTableView.isHidden = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let navbar = navigationController?.navigationBar {
            removeHairline(from: navbar)
        }
        self.fetchDefault()
//        self.fetchViewModel {
//            // TODO: do something when fetch has completed
//        }
    }
}

// MARK: - Initialize and layout views
extension EventViewController: HairlineRemovable {
    fileprivate func setupNavBar() {
        //removes hairline from bottom of navbar
        if let navbar = navigationController?.navigationBar {
            removeHairline(from: navbar)
        }
        
        let width = view.frame.width
        let headerHeight = navigationController?.navigationBar.frame.height ?? 44
        
        headerToolbar = UIToolbar(frame: CGRect(x: 0, y: 80, width: width, height: headerHeight))
        headerToolbar.backgroundColor = navigationController?.navigationBar.backgroundColor
        
        let newsSwitcher = UISegmentedControl(items: ["Events", "Schedule"])
        newsSwitcher.center = CGPoint(x: width/2, y: 80 + headerToolbar.frame.size.height/2)
        newsSwitcher.tintColor = UIColor.navRed
        newsSwitcher.selectedSegmentIndex = 0
        newsSwitcher.isUserInteractionEnabled = true
        newsSwitcher.addTarget(self, action: #selector(switchTabMode(_:)), for: .valueChanged)
        
        view.addSubview(headerToolbar)
        view.addSubview(newsSwitcher)
    }
    
    internal func switchTabMode(_ segment: UISegmentedControl) {
        let shouldShowEvents = segment.selectedSegmentIndex == 0
        eventsTableView.isHidden = !shouldShowEvents
        scheduleTableView.isHidden = shouldShowEvents
    }
}

extension EventViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TimelineTableViewCell",
                                                 for: indexPath) as! TimelineTableViewCell
        
        cell.backgroundColor = .white
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm"
        let dateFormatterTwelveHour = DateFormatter()
        dateFormatterTwelveHour.dateFormat = "h:mm a"
        
        var (title, description) = ("", "")
        
        var (startTime, endTime) : (Date?, Date?)
        
        let event = events[indexPath.row]
        (title, description, startTime, endTime) = (event.name,
                                                    "\(dateFormatter.string(from: event.startTime)) - \(dateFormatterTwelveHour.string(from: event.endTime))",
            event.startTime, event.endTime)
        
        
        if (indexPath.row > 0) {
            cell.timeline.frontColor = .lightGray
        } else {
            cell.timeline.frontColor = .clear
        }
        
        if (startTime != nil && endTime != nil && startTime! < Date() && endTime! > Date()) {
            cell.timeline.backColor = .highlightYellow
            cell.bubbleColor = .highlightYellow
            cell.timelinePoint = TimelinePoint(color: .highlightYellow, filled: true)
        } else {
            cell.timeline.backColor = .lightGray
            cell.bubbleColor = .dataGreen
            cell.timelinePoint = TimelinePoint(color: .lightGray, filled: true)
        }
        
        cell.titleLabel.text = title
        cell.descriptionLabel.text = description
        cell.descriptionLabel.font = UIFont(name: "AvenirNext-Regular", size: 16)
        cell.descriptionLabel.textColor = UIColor(r: 63, g: 63, b: 63)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Saturday, April 14th"
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let view = view as? UITableViewHeaderFooterView {
            // Customize header view
            view.textLabel?.font = UIFont(name: "AvenirNext-DemiBold", size: 24)
            view.textLabel?.textColor = UIColor(r: 63, g: 63, b: 63)
            view.textLabel?.widthAnchor.constraint(equalToConstant: 300)
            view.contentView.backgroundColor = UIColor.navBarGrey
            
            // Add divider line to header view
            let dividerLine = UIView()
            dividerLine.backgroundColor = .lightGray
            view.addSubview(dividerLine)
            dividerLine.translatesAutoresizingMaskIntoConstraints = false
            dividerLine.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
            dividerLine.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
            dividerLine.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
            dividerLine.heightAnchor.constraint(equalToConstant: 1).isActive = true
        }
    }
    
}

// MARK: - Networking
extension EventViewController {
    func fetchDefault() {
        let model: EventTableViewModel? = EventTableViewModel()
        let eventItem = HomeEventCellItem(event: Event.getDefaultEvent())
        model!.items.append(eventItem)
        
        self.setEventsTableViewModel(model!)
        self.eventsTableView.reloadData()
        self.setScheduleTableViewModel(model!)
        self.scheduleTableView.reloadData()
        self.fetchCellSpecificData {
        }
        
    }
    
    func fetchViewModel(_ completion: @escaping () -> Void) {
        EventNetworkManager.instance.fetchModel { (model) in
            guard let model = model else { return }
            if let prevItems = self.model?.items as? [HomeEventCellItem], let items = model.items as? [HomeEventCellItem], prevItems.equals(items) { return }
            DispatchQueue.main.async {
                self.setEventsTableViewModel(model)
                self.eventsTableView.reloadData()
                self.setScheduleTableViewModel(model)
                self.scheduleTableView.reloadData()
                self.fetchCellSpecificData {
                    // TODO: do something when done fetching cell specific data
                }
                completion()
            }
        }
    }
    
    func fetchCellSpecificData(_ completion: (() -> Void)? = nil) {
        guard let items = model.items as? [HomeCellItem] else { return }
        HomeAsynchronousAPIFetching.instance.fetchData(for: items, singleCompletion: { (item) in
            DispatchQueue.main.async {
                let row = items.index(where: { (thisItem) -> Bool in
                    thisItem.equals(item: item)
                })!
                let indexPath = IndexPath(row: row, section: 0)
                self.eventsTableView.reloadRows(at: [indexPath], with: .none)
            }
        }) {
            DispatchQueue.main.async {
                completion?()
            }
        }
    }
    
    
    func setEventsTableViewModel(_ model: EventTableViewModel) {
        self.model = model
        self.model.delegate = self
        eventsTableView.model = self.model
    }
    
    func setScheduleTableViewModel(_ model: EventTableViewModel) {
        events = model.items.map { (item) -> Event in
            let eventItem = item as! HomeEventCellItem
            return eventItem.event
        }
        events.sort(by: { ($0.startTime < $1.startTime) })
    }
}

// MARK: - ModularTableViewDelegate
extension EventViewController: EventCellDelegate {
    func handleUrlPressed(_ url: String) {
        let wv = WebviewController()
        wv.load(for: url)
        navigationController?.pushViewController(wv, animated: true)
    }
}

// MARK: - Prepare TableViews
extension EventViewController {
    func prepareScheduleTableView() {
        scheduleTableView = UITableView()
        scheduleTableView.backgroundColor = .navBarGrey
        scheduleTableView.separatorStyle = .none
        scheduleTableView.allowsSelection = false
        scheduleTableView.showsVerticalScrollIndicator = false
        
        // Initialize TimelineTableViewCell
        let bundle = Bundle(for: TimelineTableViewCell.self)
        let nibUrl = bundle.url(forResource: "TimelineTableViewCell", withExtension: "bundle")
        let timelineTableViewCellNib = UINib(nibName: "TimelineTableViewCell", bundle: Bundle(url: nibUrl!)!)
        scheduleTableView.register(timelineTableViewCellNib, forCellReuseIdentifier: "TimelineTableViewCell")
        
        scheduleTableView.delegate = self
        scheduleTableView.dataSource = self
        
        view.addSubview(scheduleTableView)
        
        scheduleTableView.anchorToTop(nil, left: view.leftAnchor, bottom: nil, right: view.rightAnchor)
        if #available(iOS 11.0, *) {
            scheduleTableView.topAnchor.constraint(equalTo: headerToolbar.bottomAnchor, constant: 0).isActive = true
            scheduleTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0).isActive = true
        } else {
            scheduleTableView.topAnchor.constraint(equalTo: headerToolbar.bottomAnchor, constant: 0).isActive = true
            scheduleTableView.bottomAnchor.constraint(equalTo: bottomLayoutGuide.bottomAnchor, constant: 0).isActive = true
        }
    }
    
    func prepareEventsTableView() {
        eventsTableView = ModularTableView()
        eventsTableView.backgroundColor = .clear
        eventsTableView.separatorStyle = .none
        
        view.addSubview(eventsTableView)
        
        eventsTableView.anchorToTop(nil, left: view.leftAnchor, bottom: nil, right: view.rightAnchor)
        if #available(iOS 11.0, *) {
            eventsTableView.topAnchor.constraint(equalTo: headerToolbar.bottomAnchor, constant: 0).isActive = true
            eventsTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0).isActive = true
        } else {
            eventsTableView.topAnchor.constraint(equalTo: headerToolbar.bottomAnchor, constant: 0).isActive = true
            eventsTableView.bottomAnchor.constraint(equalTo: bottomLayoutGuide.bottomAnchor, constant: 0).isActive = true
        }
        
        eventsTableView.tableFooterView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: self.view.frame.width, height: 30.0))
        
        HomeItemTypes.instance.registerCells(for: eventsTableView)
    }
}






