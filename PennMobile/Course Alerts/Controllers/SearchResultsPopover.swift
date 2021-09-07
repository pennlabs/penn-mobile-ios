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
    
    func updateWithResults(results: [CourseSection]) {
        self.results = results
        DispatchQueue.main.async {
            self.preferredContentSize = CGSize(width: self.preferredContentSize.width, height: min(CGFloat(results.count) * SearchResultsCell.cellHeight, 202))
            self.tableView = UITableView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: min(CGFloat(results.count) * SearchResultsCell.cellHeight, 215)), style: .plain)
            self.tableView.reloadData()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableView = UITableView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 215), style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        
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

