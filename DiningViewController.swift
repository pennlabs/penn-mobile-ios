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
    internal let diningHalls = ["1920 Commons", "Café at McClelland", "New College House", "English House", "Hillel"]
    internal let retail = ["Tortas Frontera", "Arch Café", "Gourmet Grocer", "Houston Market", "Joe's Cafe", "Mark's Cafe", "1920 Starbucks"]
    internal lazy var diningDictionary: [[String]] = {
        return [self.diningHalls, self.retail]
    }()
    
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
    
    internal var hiddenHeader: Int?
    internal var finishedLoading = false
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
        cell.diningTitle = diningDictionary[indexPath.section][indexPath.item]
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
    
//    override func tableView(_ tableView: UITableView, didEndDisplayingHeaderView view: UIView, forSection section: Int) {
//        if finishedLoading {
//            hiddenHeader = section
//        }
//    }
//    
//    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
//        print(section)
//        if section == hiddenHeader && finishedLoading {
//            hiddenHeader = nil
//            tableView.reloadData()
//            finishedLoading = true
//        }
//    }
    
}

private class DiningControllerCell: UITableViewCell {
    
    public var diningTitle: String! {
        didSet {
            diningImage.image = UIImage(named: diningTitle)
            label.text = diningTitle
        }
    }
    
    private let diningImage: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    
    private let mainBackground: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(r: 247, g: 247, b: 247)
        return v
    }()
    
    private let label: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "HelveticaNeue", size: 16)
        label.textColor = UIColor.warmGrey
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let openLabel: UILabel = {
        let label = UILabel()
        label.text = "Open"
        label.font = UIFont(name: "HelveticaNeue-Light", size: 13)
        label.textColor = .white
        label.backgroundColor = UIColor.coral
        label.layer.cornerRadius = 4
        label.layer.masksToBounds = true
        label.textAlignment = .center
        return label
    }()
    
    private let shadowLayer = ShadowView()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        
        setupView()
    }
    
    private func setupView() {
        //addSubview(shadowLayer)
        addSubview(mainBackground)
        
        //shadowLayer.anchorToTop(topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor)
        mainBackground.anchorToTop(topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor)
        
        mainBackground.addSubview(diningImage)
        mainBackground.addSubview(label)
        mainBackground.addSubview(openLabel)
        
        _ = diningImage.anchor(mainBackground.topAnchor, left: mainBackground.leftAnchor, bottom: mainBackground.bottomAnchor, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        diningImage.widthAnchor.constraint(equalTo: mainBackground.widthAnchor, multiplier: 0.5).isActive = true
        
        label.centerYAnchor.constraint(equalTo: mainBackground.centerYAnchor).isActive = true
        label.leftAnchor.constraint(equalTo: diningImage.rightAnchor, constant: 12).isActive = true
        
        _ = openLabel.anchor(label.bottomAnchor, left: label.leftAnchor, bottom: nil, right: nil, topConstant: 8, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 56, heightConstant: 24)
    }
    
    private func setIsOpen(isOpen: Bool) {

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

