//
//  FlingViewController.swift
//  PennMobile
//
//  Created by Josh Doman on 3/10/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//

import Foundation
import SimpleImageViewer
import TimelineTableViewCell

protocol FlingCellDelegate: ModularTableViewCellDelegate, URLSelectable {}

final class FlingTableViewModel: ModularTableViewModel {}

final class FlingViewController: GenericViewController, IndicatorEnabled {
    
    fileprivate var performersTableView: ModularTableView!
    fileprivate var scheduleTableView: UITableView!
    fileprivate var model: FlingTableViewModel!
    fileprivate var headerToolbar: UIToolbar!
    
    // TEMP COLORS - TO be deleted in favor of General/Extensions
    fileprivate static var navigationBlue = UIColor(r: 74, g: 144, b: 226)
    fileprivate static var dataGreen = UIColor(r: 118, g: 191, b: 150)
    fileprivate static var highlightYellow = UIColor(r: 240, g: 180, b: 0)
    
    var isDrawn:Bool = false
    
    // For Map Zoom
    fileprivate var mapImageView: UIImageView!

    fileprivate var performers = [FlingPerformer]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()
        prepareScheduleTableView()
        preparePerformersTableView()
        prepareMapImageView()
        
        scheduleTableView.isHidden = true
        performersTableView.isHidden = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.title = "Spring Fling"
        prepareMapBarButton()
        if let navbar = navigationController?.navigationBar {
            removeHairline(from: navbar)
        }
        
        if self.model == nil {
            showActivity()
        }
        self.fetchViewModel {
            DispatchQueue.main.async {
                self.hideActivity()
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let navbar = navigationController?.navigationBar {
            addBackHairline(from: navbar)
        }
    }
}

// MARK: - Initialize and layout views
extension FlingViewController: HairlineRemovable {
    fileprivate func setupNavBar() {
        //removes hairline from bottom of navbar
        if let navbar = navigationController?.navigationBar {
            removeHairline(from: navbar)
        }
        
        let width = view.frame.width
        let headerHeight = navigationController?.navigationBar.frame.height ?? 44
        
        headerToolbar = UIToolbar(frame: CGRect(x: 0, y: 64, width: width, height: headerHeight))
        headerToolbar.backgroundColor = navigationController?.navigationBar.backgroundColor
        
        let newsSwitcher = UISegmentedControl(items: ["Performers", "Schedule"])
        newsSwitcher.center = CGPoint(x: width/2, y: 64 + headerToolbar.frame.size.height/2)
        newsSwitcher.tintColor = UIColor.navRed
        newsSwitcher.selectedSegmentIndex = 0
        newsSwitcher.isUserInteractionEnabled = true
        newsSwitcher.addTarget(self, action: #selector(switchTabMode(_:)), for: .valueChanged)
        
        view.addSubview(headerToolbar)
        view.addSubview(newsSwitcher)
    }
    
    internal func switchTabMode(_ segment: UISegmentedControl) {
        let shouldShowPerformers = segment.selectedSegmentIndex == 0
        performersTableView.isHidden = !shouldShowPerformers
        scheduleTableView.isHidden = shouldShowPerformers
    }
}

extension FlingViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return performers.count
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if #available(iOS 11, *) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TimelineTableViewCell",
                                                     for: indexPath) as! TimelineTableViewCell
            cell.backgroundColor = .white
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "h:mm"
            let dateFormatterTwelveHour = DateFormatter()
            dateFormatterTwelveHour.dateFormat = "h:mm a"
            
            var (title, description) = ("", "")
            var (startTime, endTime) : (Date?, Date?)
            
            let performer = performers[indexPath.row]
            (title, description, startTime, endTime) = (performer.name,
                                                        "\(dateFormatter.string(from: performer.startTime)) - \(dateFormatterTwelveHour.string(from: performer.endTime))",
                performer.startTime, performer.endTime)
            
            if (indexPath.row > 0) {
                cell.timeline.frontColor = .lightGray
            } else {
                cell.timeline.frontColor = .clear
            }
            if (startTime != nil && endTime != nil && startTime! < Date() && endTime! > Date()) {
                cell.timeline.backColor = FlingViewController.highlightYellow
                cell.bubbleColor = FlingViewController.highlightYellow
                cell.timelinePoint = TimelinePoint(color: FlingViewController.highlightYellow, filled: true)
            } else {
                cell.timeline.backColor = .lightGray
                cell.bubbleColor = FlingViewController.dataGreen
                cell.timelinePoint = TimelinePoint(color: .lightGray, filled: true)
            }
            cell.titleLabel.text = title
            cell.descriptionLabel.text = description
            cell.descriptionLabel.font = UIFont(name: "AvenirNext-Regular", size: 16)
            cell.descriptionLabel.textColor = UIColor(r: 63, g: 63, b: 63)
            return cell
        } else {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "ScheduleCell") as? ScheduleCell {
                cell.setUpView(for: performers[indexPath.row], isFirst: indexPath.row == 0)
                isDrawn = true
                return cell
            }
        }
        return ScheduleCell()
    }
    
    @available(iOS 10, *)
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if #available(iOS 11, *) {
            return 100
        } else {
            return 70
        }
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
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if (indexPath.row == 0 && isDrawn) {
            if let currCell = cell as? ScheduleCell {
                currCell.redrawLine()
            }
        }
    }

}

// MARK: - Networking
extension FlingViewController {
    func fetchViewModel(_ completion: @escaping () -> Void) {
        FlingNetworkManager.instance.fetchModel { (model) in
            guard let model = model else { return }
            if let prevItems = self.model?.items as? [HomeFlingCellItem], let items = model.items as? [HomeFlingCellItem], prevItems.equals(items) { return }
            DispatchQueue.main.async {
                self.setPerformersTableViewModel(model)
                self.performersTableView.reloadData()
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
                self.performersTableView.reloadRows(at: [indexPath], with: .none)
            }
        }) {
            DispatchQueue.main.async {
                completion?()
            }
        }
    }
    
    
    func setPerformersTableViewModel(_ model: FlingTableViewModel) {
        self.model = model
        self.model.delegate = self
        performersTableView.model = self.model
    }
    
    func setScheduleTableViewModel(_ model: FlingTableViewModel) {
        performers = model.items.map { (item) -> FlingPerformer in
            let flingItem = item as! HomeFlingCellItem
            return flingItem.performer
        }
        performers.sort(by: { ($0.startTime < $1.startTime) })
    }
}

// MARK: - ModularTableViewDelegate
extension FlingViewController: FlingCellDelegate {
    func handleUrlPressed(_ url: String) {
        let wv = WebviewController()
        wv.load(for: url)
        navigationController?.pushViewController(wv, animated: true)
    }
}

// MARK: - Map Image
extension FlingViewController {
    fileprivate func prepareMapBarButton() {
        tabBarController?.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Map", style: .done, target: self, action: #selector(handleMapButtonPressed(_:)))
    }
    
    fileprivate func prepareMapImageView() {
        let image = UIImage(named: "Fling_Map")
        mapImageView = UIImageView(image: image)
        mapImageView.contentMode = .scaleAspectFill
        mapImageView.isHidden = true
        
        let widthToHeightRatio = CGFloat(2800/1884)
        let width: CGFloat = 4
        let height: CGFloat = widthToHeightRatio * width
        
        view.addSubview(mapImageView)
        _ = mapImageView.anchor(headerToolbar.topAnchor, left: nil, bottom: nil, right: view.rightAnchor, topConstant: -height, leftConstant: 0, bottomConstant: 0, rightConstant: 30, widthConstant: width, heightConstant: height)
    }
    
    @objc fileprivate func handleMapButtonPressed(_ sender: Any?) {
        let configuration = ImageViewerConfiguration { config in
            config.imageView = mapImageView
        }
        
        let imageViewerController = ImageViewerController(configuration: configuration)
        present(imageViewerController, animated: true)
    }
}

// MARK: - Prepare TableViews
extension FlingViewController {
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
        scheduleTableView.register(ScheduleCell.self, forCellReuseIdentifier: "ScheduleCell")
        
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

    func preparePerformersTableView() {
        performersTableView = ModularTableView()
        performersTableView.backgroundColor = .clear
        performersTableView.separatorStyle = .none
        
        view.addSubview(performersTableView)
        
        performersTableView.anchorToTop(nil, left: view.leftAnchor, bottom: nil, right: view.rightAnchor)
        if #available(iOS 11.0, *) {
            performersTableView.topAnchor.constraint(equalTo: headerToolbar.bottomAnchor, constant: 0).isActive = true
            performersTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0).isActive = true
        } else {
            performersTableView.topAnchor.constraint(equalTo: headerToolbar.bottomAnchor, constant: 0).isActive = true
            performersTableView.bottomAnchor.constraint(equalTo: bottomLayoutGuide.bottomAnchor, constant: 0).isActive = true
        }
        
        performersTableView.tableFooterView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: self.view.frame.width, height: 30.0))
        
        HomeItemTypes.instance.registerCells(for: performersTableView)
    }
}






