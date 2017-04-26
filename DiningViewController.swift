//
//  DiningViewController.swift
//  PennMobile
//
//  Created by Josh Doman on 3/12/17.
//  Copyright © 2017 PennLabs. All rights reserved.
//

import UIKit

class DiningViewController: GenericTableViewController {
    
    internal let titles = ["Dining Halls", "Retail Dining"]
    internal let diningHalls = ["1920 Commons", "McClelland Express", "New College House", "English House", "Falk Kosher Dining"]
    internal let retail = ["Tortas Frontera", "Gourmet Grocer", "Houston Market", "Joe's Café", "Mark's Café", "Beefsteak", "Starbucks"]
    internal var diningDictionary: [[DiningHall]] {
        return [dining, retailHalls]
    }
    
    var dining: [DiningHall]!
    var retailHalls: [DiningHall]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Dining"
        self.screenName = "Dining"
        
        tableView.separatorStyle = .none
        tableView.dataSource = self
        
        registerHeadersAndCells()
        
        //Default settings for dining halls
        dining = generateDiningHalls(for: diningHalls)
        retailHalls = generateDiningHalls(for: retail)
        
    }
    
    internal let headerView = "header"
    internal let diningCell = "cell"
    
    private func registerHeadersAndCells() {
        tableView.register(DiningControllerCell.self, forCellReuseIdentifier: diningCell)
        tableView.register(DiningHeaderView.self, forHeaderFooterViewReuseIdentifier: headerView)
    }
    
    internal func generateDiningHalls(for diningHalls: [String]) -> [DiningHall] {
        var arr = [DiningHall]()
        for hall in diningHalls {
            arr.append(DiningHall(name: hall, timeRemaining: 0))
        }
        return arr
    }
    
    func updateTimesForDiningHalls() {
        NetworkManager.getDiningData(for: self.dining) { (diningHalls) in
            
            self.dining = diningHalls
            
            NetworkManager.getDiningData(for: self.retailHalls, callback: { (diningHalls) in
                self.retailHalls = diningHalls
                
                let when = DispatchTime.now() + 0.3
                DispatchQueue.main.asyncAfter(deadline: when, execute: {
                    self.tableView.reloadData()
                })
            })
        }
    }
    
    override func updateData() {
        updateTimesForDiningHalls()
    }
}

extension DiningViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? diningHalls.count : retail.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: diningCell, for: indexPath) as! DiningControllerCell
        cell.diningHall = diningDictionary[indexPath.section][indexPath.item]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: headerView) as! DiningHeaderView
        view.title = titles[section]
        return view
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 112
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 54
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
        let diningHall = diningDictionary[indexPath.section][indexPath.item]
        let ddc = DiningDetailViewController()
        ddc.diningHall = diningHall
        navigationController?.pushViewController(ddc, animated: true)
    }
    
}

private class DiningHeaderView: UITableViewHeaderFooterView {
    
    public var title: String! {
        didSet {
            label.text = title
        }
    }
    
    private let label: UILabel = {
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

