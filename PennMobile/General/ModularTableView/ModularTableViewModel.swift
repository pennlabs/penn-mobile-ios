//
//  ModularTableViewModel.swift
//  PennMobile
//
//  Created by Josh Doman on 3/5/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//

import Foundation

protocol ModularTableViewModelDelegate: ModularTableViewCellDelegate {}

protocol ModularTableViewModel: UITableViewDataSource, UITableViewDelegate {
    var items: [ModularTableViewItem] { get set }
    var delegate: ModularTableViewCellDelegate! { get set }
}

// MARK: - UITableViewDataSource
extension ModularTableViewModel {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = items[indexPath.row]
        let identifier = item.cellIdentifier
        var cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! ModularTableViewCell
        cell.item = item
        cell.delegate = self.delegate
        return cell as! UITableViewCell
    }
}

// MARK: - UITableViewDelegate
extension ModularTableViewModel {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let item = items[indexPath.row]
        return item.cellHeight
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        let item = items[indexPath.row]
        return item.cellHeight
    }
}
