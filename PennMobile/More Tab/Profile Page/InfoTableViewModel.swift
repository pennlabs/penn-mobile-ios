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
    var schools = [School]()
    var majors = [Major]()
    var info = [String]()
    var filteredInfo = [String]()
    var filteredSchools = [School]()
    var selectedSchools = Set<School>()
    var filteredMajors = [Major]()
    var selectedMajors = Set<Major>()

    var delegate: InfoTableViewModelDelegate!
    var isMajors = true

    override init() {
        super.init()
        prepareSchools()
        prepareMajors()

    }

    func updateAccount() {

        var account = Account.getAccount()!
        var student = account.student

        if isMajors {
            student.major = Array(selectedMajors)
        } else {
            student.school = Array(selectedSchools)
        }

        account.student = student

        Account.saveAccount(account)

        let encoder = JSONEncoder()
        if let data = try? encoder.encode(account) {
            OAuth2NetworkManager.instance.getAccessToken { (token) in
                guard let token = token else { return }

                var request = URLRequest(url: URL(string: "https://platform.pennlabs.org/accounts/me")!, accessToken: token)
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                request.httpBody = data
                request.httpMethod = "PATCH"

                let str = String(decoding: data, as: UTF8.self)
                print(str)

                let task = URLSession.shared.dataTask(with: request, completionHandler: {data, response, _ in
                    print(response)
                    print(String(decoding: data!, as: UTF8.self))

                })
                task.resume()
            }
        }
    }

    func prepareSchools() {
        DispatchQueue.main.async {
            ProfilePageNetworkManager.instance.getSchools { result in
                switch result {
                case .success(let schools):
                    self.schools = schools
                    self.filteredSchools = schools
                    self.selectedSchools = Set(Account.getAccount()!.student.school)
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
                    self.selectedMajors = Set(Account.getAccount()!.student.major)
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
            if selectedMajors.contains(filteredMajors[indexPath.row]) {
                cell.accessoryType = .checkmark
            } else {
                cell.accessoryType = .none
            }
        } else {

            content.text = filteredSchools[indexPath.row].name
            if selectedSchools.contains(filteredSchools[indexPath.row]) {
                cell.accessoryType = .checkmark
            } else {
                cell.accessoryType = .none
            }
        }
        cell.contentConfiguration = content
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        // TODO: Fix this - it has a lot of repeated code
        if isMajors {
            if selectedMajors.contains(filteredMajors[indexPath.row]) {
                selectedMajors.remove(filteredMajors[indexPath.row])
                tableView.cellForRow(at: indexPath)!.accessoryType = .none
            } else {
                selectedMajors.insert(filteredMajors[indexPath.row])
                tableView.cellForRow(at: indexPath)!.accessoryType = .checkmark
            }
        } else {
            if selectedSchools.contains(filteredSchools[indexPath.row]) {
                selectedSchools.remove(filteredSchools[indexPath.row])
                tableView.cellForRow(at: indexPath)!.accessoryType = .none
            } else {
                selectedSchools.insert(filteredSchools[indexPath.row])
                tableView.cellForRow(at: indexPath)!.accessoryType = .checkmark
            }
        }
        tableView.deselectRow(at: indexPath, animated: true)

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
            filteredMajors = searchController.searchBar.text == "" ? majors : majors.filter { (item: Major) -> Bool in
                return item.name.range(of: searchController.searchBar.text!, options: .caseInsensitive, range: nil, locale: nil) != nil
            }
        } else {
            filteredSchools = searchController.searchBar.text == "" ? schools : schools.filter { (item: School) -> Bool in
                return item.name.range(of: searchController.searchBar.text!, options: .caseInsensitive, range: nil, locale: nil) != nil
            }
        }
        self.delegate.reloadTableData()
    }
}
