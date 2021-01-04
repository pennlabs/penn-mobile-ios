//
//  SearchResultsPopover.swift
//  PennMobile
//
//  Created by Raunaq Singh on 12/26/20.
//  Copyright © 2020 PennLabs. All rights reserved.
//

import Foundation
import UIKit

protocol CourseSearchDelegate {
    func selectSection(section : CourseSection)
}

class SearchResultsPopover: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var tableView = UITableView()
    var results: [CourseSection] = []
    
    var delegate : CourseSearchDelegate?
    
    var tableHeight: CGFloat {
        return CGFloat(results.count) * SearchResultsCell.cellHeight
    }
    
    func setHeight() {
        self.preferredContentSize = CGSize(width: 300, height: min(tableHeight + 5, 215))
        tableView.frame = CGRect(x: self.view.bounds.origin.x, y: self.view.bounds.origin.y, width: tableView.bounds.width, height: min(tableHeight + 5, 215))
    }
    
    func updateWithResults(results: [CourseSection]) {
        self.results = results
        DispatchQueue.main.async {
            self.setHeight()
            self.tableView.reloadData()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        tableView = UITableView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: tableHeight), style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        
        tableView.register(SearchResultsCell.self, forCellReuseIdentifier: SearchResultsCell.identifier)
        self.view.addSubview(tableView)
        
        self.view.backgroundColor = .white
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SearchResultsCell.identifier, for: indexPath) as! SearchResultsCell
        cell.selectionStyle = .none
        //cell.backgroundColor = .red
        if indexPath.row < results.count {
            cell.section = results[indexPath.row]
        } else {
            return UITableViewCell()
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.selectSection(section: results[indexPath.row])
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return SearchResultsCell.cellHeight
    }
    
    
}

