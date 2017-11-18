//
//  DiningViewController.swift
//  PennMobile
//
//  Created by Josh Doman on 3/12/17.
//  Copyright © 2017 PennLabs. All rights reserved.
//

class DiningViewController: GenericTableViewController {
    
    internal let titles = ["Dining Halls", "Retail Dining"]
    internal let diningHalls = ["1920 Commons", "McClelland Express", "New College House", "Hill House", "English House", "Falk Kosher Dining"]
    internal let retail = ["Tortas Frontera", "Gourmet Grocer", "Houston Market", "Joe's Café", "Mark's Café", "Beefsteak", "Starbucks"]
    
    internal lazy var diningDictionary: [[DiningVenue]] = [self.generateVenues(for: self.diningHalls), self.generateVenues(for: self.retail)]
    
    fileprivate var announcement: String? = nil //set to nil if no announcement is to be shown
    fileprivate var showAnnouncement: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.separatorStyle = .none
        tableView.dataSource = self
        
        self.title = "Dining"
        self.screenName = "Dining"
        
        registerHeadersAndCells()
        updateVenueTimes()
    }
    
    internal let headerView = "header"
    internal let diningCell = "cell"
    internal let announcementHeader = "announcement"
    
    private func registerHeadersAndCells() {
        tableView.register(DiningCell.self, forCellReuseIdentifier: diningCell)
        tableView.register(DiningHeaderView.self, forHeaderFooterViewReuseIdentifier: headerView)
        if showAnnouncement {
            tableView.register(AnnouncementHeaderView.self, forHeaderFooterViewReuseIdentifier: announcementHeader)
        }
    }
    
    private func generateVenues(for venues: [String]) -> [DiningVenue] {
        var arr = [DiningVenue]()
        for venue in venues {
            arr.append(DiningVenue(name: venue))
        }
        return arr
    }
    
    //called when view appears
    override func updateData() {
        updateVenueTimes()
    }
}

//Mark: Setting up table view
extension DiningViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return showAnnouncement ? 3 : 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if showAnnouncement {
            return section == 0 ? 0 : (section == 1 ? diningHalls.count : retail.count)
        } else {
            return section == 0 ? diningHalls.count : retail.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: diningCell, for: indexPath) as! DiningCell
        let diningSection = showAnnouncement ? (indexPath.section - 1) : indexPath.section
        cell.venue = diningDictionary[diningSection][indexPath.item]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if showAnnouncement && section == 0, let announcement = self.announcement {
            let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: announcementHeader) as! AnnouncementHeaderView
            view.announcement = announcement
            return view
        } else {
            let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: headerView) as! DiningHeaderView
            let titleSection = showAnnouncement ? section - 1 : section
            view.label.text = titles[titleSection]
            return view
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 112
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return (showAnnouncement && section == 0) ? 130 : 54
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.layer.cornerRadius = 8
        cell.layer.shadowOffset = .zero
        cell.layer.shadowRadius = 5
        cell.layer.shadowOpacity = 0.2
        cell.layer.shadowPath = UIBezierPath(rect: cell.bounds).cgPath
        cell.layer.shouldRasterize = true
        cell.layer.rasterizationScale = UIScreen.main.scale
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let ddc = DiningDetailViewController()
        let titleSection = showAnnouncement ? indexPath.section - 1 : indexPath.section
        ddc.venue = diningDictionary[titleSection][indexPath.item]
        navigationController?.pushViewController(ddc, animated: true)
        
        DatabaseManager.shared.trackEvent(vcName: "Dining", event: ddc.venue.name)
    }
}

//Mark: Networking to retrieve today's times
extension DiningViewController {
    fileprivate func updateVenueTimes() {
        var allVenues = diningHalls
        allVenues.append(contentsOf: retail)
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        _ = DiningAPI.getVenueHours(for: allVenues).then { venueDictionary -> Void in
            
            DispatchQueue.main.async {
                self.updateUIWithVenues(venueDictionary)
            }
            
            }.always {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }.catch { error in
                print(error)
        }
    }
    
    fileprivate func updateUIWithVenues(_ venueDictionary: Dictionary<String, DiningVenue>) {
        for (key, venue) in venueDictionary {
            if let index = diningHalls.index(of: key) {
                diningDictionary[0][index] = venue
            } else if let index = retail.index(of: key) {
                diningDictionary[1][index] = venue
            }
        }
        tableView.reloadData()
    }
}

private class DiningHeaderView: UITableViewHeaderFooterView {
    
    var label: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "HelveticaNeue-Light", size: 18)
        label.textColor = UIColor.warmGrey
        return label
    }()
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        contentView.backgroundColor = .white
        
        addSubview(label)
        _ = label.anchor(nil, left: leftAnchor, bottom: bottomAnchor, right: nil, topConstant: 0, leftConstant: 28, bottomConstant: 10, rightConstant: 0, widthConstant: 0, heightConstant: 0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class ShadowView: UIView {
    override var bounds: CGRect {
        didSet {
            setupShadow()
        }
    }
    
    private func setupShadow() {
        self.layer.cornerRadius = 8
        self.layer.shadowOffset = CGSize(width: 0, height: 3)
        self.layer.shadowRadius = 3
        self.layer.shadowOpacity = 0.2
        self.layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
        self.layer.shouldRasterize = true
        self.layer.rasterizationScale = UIScreen.main.scale
    }
}

