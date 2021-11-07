//
//  InfoTableViewModel.swift
//  PennMobile
//
//  Created by Andrew Antenberg on 10/11/21.
//  Copyright © 2021 PennLabs. All rights reserved.
//

import Foundation
import UIKit

protocol InfoTableViewModelDelegate {
    func reloadTableData()
}

class InfoTableViewModel: NSObject {
    var schools = [AccountSchool]()
    var majors = [AccountMajor]()
    var info = [String]()
    var filteredInfo = [String]()
    var filteredSchools = [AccountSchool]()
    var selectedSchools = Set<String>()
    var filteredMajors = [AccountMajor]()
    var selectedMajors = Set<String>()
    
    var delegate: InfoTableViewModelDelegate!
    var isMajors = true
    
    override init() {
        super.init()
        prepareSchools()
        prepareMajors()

    }
    
    func prepareSchools() {
        DispatchQueue.main.async {
            ProfilePageNetworkManager.instance.getSchools { result in
                switch result {
                case .success(let schools):
                    self.schools = schools
                    self.filteredSchools = schools
                    self.delegate.reloadTableData()
                case .failure:
                    break
                }
            }
        }
    }
    
    func prepareMajors() {
        DispatchQueue.main.async {
            ProfilePageNetworkManager.instance.getMajors { result in
                switch result {
                case .success(let majors):
                    self.majors = majors
                    self.filteredMajors = majors
                    self.delegate.reloadTableData()
                case .failure:
                    break
                }
            }
        }
    }
    
}

extension InfoTableViewModel: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isMajors {
            return filteredMajors.count
        }
        return filteredSchools.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
        var content = cell.defaultContentConfiguration()
        if isMajors {
            content.text = filteredMajors[indexPath.row].name
            if selectedMajors.contains(filteredMajors[indexPath.row].name) {
                cell.accessoryType = .checkmark
            } else {
                cell.accessoryType = .none
            }
        } else {
            
            content.text = filteredSchools[indexPath.row].name
            if selectedSchools.contains(filteredSchools[indexPath.row].name) {
                cell.accessoryType = .checkmark
            } else {
                cell.accessoryType = .none
            }
        }
        cell.contentConfiguration = content
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isMajors {
            if selectedMajors.contains(filteredMajors[indexPath.row].name) {
                selectedMajors.remove(filteredMajors[indexPath.row].name)
                tableView.cellForRow(at: indexPath)!.accessoryType = .none
            } else {
                selectedMajors.insert(filteredMajors[indexPath.row].name)
                tableView.cellForRow(at: indexPath)!.accessoryType = .checkmark
            }
        } else {
            if selectedSchools.contains(filteredSchools[indexPath.row].name) {
                selectedSchools.remove(filteredSchools[indexPath.row].name)
                tableView.cellForRow(at: indexPath)!.accessoryType = .none
            } else {
                selectedSchools.insert(filteredSchools[indexPath.row].name)
                tableView.cellForRow(at: indexPath)!.accessoryType = .checkmark
            }
        }
        tableView.deselectRow(at: indexPath, animated: true)
        //tableView.reloadData()
        
        
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return nil
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

}

extension InfoTableViewModel: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        if isMajors {
            filteredMajors = searchController.searchBar.text == "" ? majors : majors.filter { (item: AccountMajor) -> Bool in
                return item.name.range(of: searchController.searchBar.text!, options: .caseInsensitive, range: nil, locale: nil) != nil
            }
        } else {
            filteredSchools = searchController.searchBar.text == "" ? schools : schools.filter { (item: AccountSchool) -> Bool in
                return item.name.range(of: searchController.searchBar.text!, options: .caseInsensitive, range: nil, locale: nil) != nil
            }
        }
        self.delegate.reloadTableData()
    }
}
