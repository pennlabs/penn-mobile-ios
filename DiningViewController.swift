//
//  NewDiningViewController.swift
//  PennMobile
//
//  Created by Josh Doman on 3/12/17.
//  Copyright © 2017 PennLabs. All rights reserved.
//

import UIKit

class DiningViewController: GenericTableViewController {
    
    internal let titles = ["Dining Halls", "Retail Dining"]
    internal let diningHalls = ["1920 Commons", "Café at Mcclelland", "New College House", "Kings Court English House", "Hillel"]
    internal let retail = ["Tortas Frontera", "Arch Café", "Gourmet Grocer", "Houston Market", "Joe's Cafe", "Mark's Cafe", "1920 Starbucks"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Dining"
        
        tableView.separatorStyle = .none
        tableView.dataSource = self
        
        registerHeadersAndCells()
    }
    
    internal let headerView = "header"
    internal let diningCell = "cell"
    
    private func registerHeadersAndCells() {
        tableView.register(DiningControllerCell.self, forCellReuseIdentifier: diningCell)
        tableView.register(DiningHeaderView.self, forHeaderFooterViewReuseIdentifier: headerView)
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
        let cell = tableView.dequeueReusableCell(withIdentifier: diningCell, for: indexPath)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: headerView) as! DiningHeaderView
        view.title = titles[section]
        return view
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }
    
}

private class DiningControllerCell: UITableViewCell {
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = .blue
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
        return label
    }()
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        contentView.backgroundColor = .white
        
        addSubview(label)
        _ = label.anchor(nil, left: leftAnchor, bottom: bottomAnchor, right: nil, topConstant: 0, leftConstant: 40, bottomConstant: 8, rightConstant: 0, widthConstant: 0, heightConstant: 0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

