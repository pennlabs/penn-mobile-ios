//
//  CourseAlertCreateController.swift
//  PennMobile
//
//  Created by Raunaq Singh on 10/25/20.
//  Copyright © 2020 PennLabs. All rights reserved.
//
import UIKit
import Foundation

protocol FetchPCADataProtocol {
    func fetchAlerts()
    func fetchSettings()
}

class CourseAlertCreateController: GenericViewController, IndicatorEnabled {
    
    fileprivate var searchBar = UISearchBar()
    fileprivate var alertTypeView: UIView!
    fileprivate var alertTypeSeparator: UIView!
    fileprivate var switchLabel: UILabel!
    fileprivate var alertSwitcher: UISegmentedControl!
    fileprivate var navBar: UINavigationBar!
    
    fileprivate var searchPromptView: UIView!
    fileprivate var noResultsView: UIView!
    
    fileprivate var searchResults: [CourseSection] = []
    fileprivate var resultsTableView = UITableView()
    
    fileprivate var mostRecentSearch: String = ""
    
    var delegate: FetchPCADataProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
}

// MARK: - Setup UI
extension CourseAlertCreateController {
    
    fileprivate func setupUI() {
        setupCustomNavBar()
        setupSearchBar()
        setupAlertType()
        setupResultsTableView()
        setupAlertTypeSeparator()
        setupSearchPromptView()
        setupNoSearchResultsView()
    }
    
    fileprivate func setupCustomNavBar() {
        navBar = UINavigationBar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 54))
        view.addSubview(navBar)
        let navItem = UINavigationItem(title: "Create Alert")
        navItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .done, target: self, action: #selector(handleCancel))
        navBar.setItems([navItem], animated: false)
    }
    
    fileprivate func setupSearchBar() {
        searchBar.delegate = self
        searchBar.placeholder = "Ex. ECON 001"
        searchBar.returnKeyType = .search
        searchBar.autocapitalizationType = .allCharacters
        searchBar.autocorrectionType = .no
        searchBar.keyboardType = .asciiCapable
        
        view.addSubview(searchBar)
        
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.topAnchor.constraint(equalTo: navBar.bottomAnchor, constant: 0).isActive = true
        searchBar.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        searchBar.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        searchBar.heightAnchor.constraint(equalToConstant: 60).isActive = true
    }
    
    fileprivate func setupAlertType() {
        switchLabel = UILabel()
        switchLabel.text = "Alert me:"
        switchLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        switchLabel.textColor = .labelSecondary
        switchLabel.textAlignment = .left
        switchLabel.numberOfLines = 0
        switchLabel.sizeToFit()
        
        alertSwitcher = UISegmentedControl(items: ["Once", "Until I cancel"])
        alertSwitcher.tintColor = UIColor.navigation
        alertSwitcher.selectedSegmentIndex = 0
        alertSwitcher.isUserInteractionEnabled = true
        
        alertTypeView = UIView()
        alertTypeView.addSubview(switchLabel)
        alertTypeView.addSubview(alertSwitcher)
        
        switchLabel.translatesAutoresizingMaskIntoConstraints = false
        switchLabel.leadingAnchor.constraint(equalTo: alertTypeView.leadingAnchor, constant: 0).isActive = true
        switchLabel.centerYAnchor.constraint(equalTo: alertTypeView.centerYAnchor).isActive = true

        alertSwitcher.translatesAutoresizingMaskIntoConstraints = false
        alertSwitcher.leadingAnchor.constraint(equalTo: switchLabel.trailingAnchor, constant: 10).isActive = true
        alertSwitcher.centerYAnchor.constraint(equalTo: alertTypeView.centerYAnchor).isActive = true
        
        view.addSubview(alertTypeView)
        
        alertTypeView.translatesAutoresizingMaskIntoConstraints = false
        alertTypeView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 0).isActive = true
        alertTypeView.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0).isActive = true
        alertTypeView.widthAnchor.constraint(equalToConstant: switchLabel.frame.size.width + alertSwitcher.frame.size.width + 10).isActive = true
        alertTypeView.heightAnchor.constraint(equalToConstant: alertSwitcher.frame.size.height + 22).isActive = true
    }

    fileprivate func setupResultsTableView() {
        resultsTableView.delegate = self
        resultsTableView.dataSource = self
        
        resultsTableView.keyboardDismissMode = .onDrag
        resultsTableView.register(SearchResultsCell.self, forCellReuseIdentifier: SearchResultsCell.identifier)
        
        view.addSubview(resultsTableView)
        
        resultsTableView.translatesAutoresizingMaskIntoConstraints = false
        resultsTableView.topAnchor.constraint(equalTo: alertTypeView.bottomAnchor, constant: 0).isActive = true
        resultsTableView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0).isActive = true
        resultsTableView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0).isActive = true
        resultsTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
    }
    
    fileprivate func setupAlertTypeSeparator() {
        alertTypeSeparator = UIView()
        alertTypeSeparator.backgroundColor = .grey5

        view.addSubview(alertTypeSeparator)

        alertTypeSeparator.translatesAutoresizingMaskIntoConstraints = false
        alertTypeSeparator.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0).isActive = true
        alertTypeSeparator.widthAnchor.constraint(equalToConstant: view.frame.size.width).isActive = true
        alertTypeSeparator.heightAnchor.constraint(equalToConstant: 1).isActive = true
        alertTypeSeparator.topAnchor.constraint(equalTo: resultsTableView.topAnchor, constant: 0).isActive = true
    }
    
    fileprivate func setupSearchPromptView() {
        searchPromptView = UIView()
        
        let searchLabel = UILabel()
        searchLabel.text = "Search courses for the current semester."
        searchLabel.font = UIFont.avenirMedium
        searchLabel.textColor = .lightGray
        searchLabel.textAlignment = .center
        searchLabel.numberOfLines = 0
        searchLabel.sizeToFit()
        
        searchPromptView.addSubview(searchLabel)
        
        searchLabel.translatesAutoresizingMaskIntoConstraints = false
        searchLabel.centerXAnchor.constraint(equalTo: searchPromptView.centerXAnchor, constant: 0).isActive = true
        searchLabel.centerYAnchor.constraint(equalTo: searchPromptView.centerYAnchor, constant: -150).isActive = true
        
        searchLabel.widthAnchor.constraint(equalTo: searchPromptView.widthAnchor, multiplier: 0.9).isActive = true
        
        view.addSubview(searchPromptView)
        
        searchPromptView.translatesAutoresizingMaskIntoConstraints = false
        searchPromptView.topAnchor.constraint(equalTo: alertTypeView.bottomAnchor, constant: 1).isActive = true
        searchPromptView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0).isActive = true
        searchPromptView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0).isActive = true
        searchPromptView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
    }
    
    fileprivate func setupNoSearchResultsView() {
        noResultsView = UIView()
        
        let searchLabel = UILabel()
        searchLabel.text = "No results found."
        searchLabel.font = UIFont.avenirMedium
        searchLabel.textColor = .lightGray
        searchLabel.textAlignment = .center
        searchLabel.numberOfLines = 0
        searchLabel.sizeToFit()
        
        noResultsView.addSubview(searchLabel)
        
        searchLabel.translatesAutoresizingMaskIntoConstraints = false
        searchLabel.centerXAnchor.constraint(equalTo: noResultsView.centerXAnchor, constant: 0).isActive = true
        searchLabel.centerYAnchor.constraint(equalTo: noResultsView.centerYAnchor, constant: -150).isActive = true
        
        searchLabel.widthAnchor.constraint(equalTo: noResultsView.widthAnchor, multiplier: 0.9).isActive = true
        
        view.addSubview(noResultsView)
        
        noResultsView.translatesAutoresizingMaskIntoConstraints = false
        noResultsView.topAnchor.constraint(equalTo: alertTypeView.bottomAnchor, constant: 1).isActive = true
        noResultsView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0).isActive = true
        noResultsView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0).isActive = true
        noResultsView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
        
        noResultsView.isHidden = true
    }
    
}

// MARK: - Event Handlers
extension CourseAlertCreateController: ShowsAlert {
    
    @objc fileprivate func handleCancel() {
        dismiss(animated: true, completion: nil)
    }
    
    fileprivate func confirmAlert(section: CourseSection) {
        
        var message = "Create a one-time alert for " + section.section + "?"
        if (alertSwitcher.selectedSegmentIndex == 1) {
            message = "Create a repeated alert for " + section.section + "? This will repeat until the end of the semester."
        }
        
        self.showOption(withMsg: message, title: "Confirm New Alert", onAccept: {
            CourseAlertNetworkManager.instance.createRegistration(section: section.section, autoResubscribe: (self.alertSwitcher.selectedSegmentIndex == 1), callback: {(success, response, error) in
                DispatchQueue.main.async {
                    if success {
                        self.showAlert(withMsg: response, title: "Success!", completion: self.handleCancel)
                        self.delegate?.fetchAlerts()
                    } else if !response.isEmpty {
                        self.showAlert(withMsg: response, title: "Uh-Oh!", completion: nil)
                    }
                }
            })
        }, onCancel: nil)
        
    }
    
}

// MARK: - TableView Functions
extension CourseAlertCreateController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SearchResultsCell.identifier, for: indexPath) as! SearchResultsCell
        cell.selectionStyle = .none
        cell.section = searchResults[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        confirmAlert(section: searchResults[indexPath.row])
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (searchResults[indexPath.row].instructors.isEmpty) {
            return SearchResultsCell.noInstructorCellHeight
        }
        return SearchResultsCell.cellHeight
    }
}


// MARK: - Search Bar Functions
extension CourseAlertCreateController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.searchResults = []
        self.resultsTableView.reloadData()
        
        handleSearchQuery()
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        self.searchBar.resignFirstResponder()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        handleSearchQuery()
    }
    
    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        self.searchBar.resignFirstResponder()
    }
    
    @objc func handleSearchQuery() {
        let searchText = searchBar.text ?? ""
        mostRecentSearch = searchText
        
        if (searchText == "") {
            hideAllActivity()
            searchPromptView.isHidden = false
            noResultsView.isHidden = true
        } else {
            searchPromptView.isHidden = true
            noResultsView.isHidden = true
            
            showActivity(isUserInteractionEnabled: true)
            
            CourseAlertNetworkManager.instance.getSearchedCourses(searchText: searchText) { (results) in
                if (searchText == self.mostRecentSearch) {
                    DispatchQueue.main.async {
                        self.hideAllActivity()
                    }
                    if let results = results {
                        DispatchQueue.main.async {
                            self.searchResults = results
                            if (results.isEmpty) {
                                self.noResultsView.isHidden = false
                            }
                        }
                    } else {
                        self.searchResults = []
                        self.noResultsView.isHidden = false
                    }
                    DispatchQueue.main.async {
                        self.resultsTableView.reloadData()
                    }
                }
            }
        }
        
    }
    
}
