//
//  GSROverhallController.swift
//  PennMobile
//
//  Created by Zhilei Zheng on 2/2/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//

import UIKit

class GSROverhallController: GenericViewController {
    
    internal let roomCell = "roomCell"
    internal let cellSize: CGFloat = 100
    
    var venues:[Int:String] = [:]
    
    internal lazy var tableView: UITableView = {
        let tv = UITableView(frame: .zero)
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.dataSource = self
        tv.delegate = self
        tv.register(RoomCell.self, forCellReuseIdentifier: self.roomCell)
        tv.tableFooterView = UIView()
        return tv
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        GSROverhaulManager.instance.getLocations() { (locations) in
            DispatchQueue.main.async {
                self.refreshLocationData(dict: locations ?? [:])
            }
        }
        GSROverhaulManager.instance.getAvailability(for: 1086) { (_) in
        }
    }
    
    private func setupView() {
        self.title = "Study Room Booking"
        view.addSubview(tableView)
        _ = tableView.anchor(view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, topConstant: 20.0, leftConstant: 0.0, bottomConstant: 0.0, rightConstant: 0.0, widthConstant: 0, heightConstant: 0)
    }
    
    private func refreshLocationData(dict: [Int:String]) {
        venues = dict
        tableView.reloadData()
        print(venues)
    }
    

}


extension GSROverhallController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return venues.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return Array(venues.values)[section]
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: roomCell,
                                             for: indexPath)
        cell.backgroundColor = UIColor.black
        return cell
    }
    
}
