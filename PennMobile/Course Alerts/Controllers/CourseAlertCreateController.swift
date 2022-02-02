//
//  CourseAlertAddController.swift
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

class CourseAlertCreateController: GenericViewController {

    fileprivate var searchBar = UISearchBar()
    fileprivate var alertSwitch: UISwitch!
    fileprivate var addButton: UIButton!
    fileprivate var switchLabel: UILabel!
    fileprivate var headerLabel: UILabel!

    fileprivate var navBar: UINavigationBar!

    fileprivate var searchResults: SearchResultsPopover!

    fileprivate var sectionToAlert: CourseSection?

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
        setupHeaderLabel()
        setupSwitchLabel()
        setupAlertSwitch()
        setupAddButton()
        setupResultsPopover()
    }

    fileprivate func setupCustomNavBar() {
        navBar = UINavigationBar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 44))
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

        searchBar.layer.borderWidth = 1
        searchBar.layer.borderColor = UIColor.white.cgColor

        view.addSubview(searchBar)

        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.topAnchor.constraint(equalTo: navBar.bottomAnchor, constant: 125).isActive = true
        searchBar.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        searchBar.widthAnchor.constraint(equalToConstant: 300).isActive = true
        searchBar.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }

    fileprivate func setupHeaderLabel() {
        headerLabel = UILabel()
        headerLabel.text = "Get Alerted When a Course Opens Up"
        headerLabel.font = UIFont.avenirMedium
        headerLabel.textColor = .labelSecondary
        headerLabel.textAlignment = .center
        headerLabel.numberOfLines = 0
        headerLabel.sizeToFit()

        view.addSubview(headerLabel)

        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        headerLabel.leadingAnchor.constraint(equalTo: searchBar.leadingAnchor, constant: -12).isActive = true
        headerLabel.bottomAnchor.constraint(equalTo: searchBar.topAnchor, constant: -25).isActive = true
        headerLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }

    fileprivate func setupSwitchLabel() {
        switchLabel = UILabel()
        switchLabel.text = "Repeat alert until I cancel"
        switchLabel.font = UIFont.interiorTitleFont
        switchLabel.textColor = .labelSecondary
        switchLabel.textAlignment = .center
        switchLabel.numberOfLines = 0
        switchLabel.sizeToFit()

        view.addSubview(switchLabel)

        switchLabel.translatesAutoresizingMaskIntoConstraints = false
        switchLabel.leadingAnchor.constraint(equalTo: searchBar.leadingAnchor, constant: 0).isActive = true
        switchLabel.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 20).isActive = true
        switchLabel.widthAnchor.constraint(equalToConstant: 220).isActive = true
    }

    fileprivate func setupAlertSwitch() {
        alertSwitch = UISwitch()
        alertSwitch.setOn(false, animated: false)
        alertSwitch.onTintColor = .baseLabsBlue

        view.addSubview(alertSwitch)

        alertSwitch.translatesAutoresizingMaskIntoConstraints = false
        alertSwitch.centerYAnchor.constraint(equalTo: switchLabel.centerYAnchor).isActive = true
        alertSwitch.trailingAnchor.constraint(equalTo: searchBar.trailingAnchor, constant: -8).isActive = true
    }

    fileprivate func setupAddButton() {
        addButton = UIButton()
        addButton.setTitle("Alert me", for: .normal)
        addButton.setTitleColor(.white, for: .normal)
        addButton.titleLabel?.font =  UIFont.primaryTitleFont
        addButton.backgroundColor = .baseLabsBlue
        addButton.layer.cornerRadius = 8
        addButton.addTarget(self, action: #selector(alertButton), for: .touchUpInside)

        view.addSubview(addButton)

        addButton.translatesAutoresizingMaskIntoConstraints = false
        addButton.topAnchor.constraint(equalTo: alertSwitch.bottomAnchor, constant: 25).isActive = true
        addButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        addButton.widthAnchor.constraint(equalToConstant: 110).isActive = true
        addButton.heightAnchor.constraint(equalToConstant: 50).isActive = true

    }

    func setupResultsPopover() {
        searchResults = SearchResultsPopover()
        searchResults.modalPresentationStyle = .popover
        searchResults.delegate = self

        let searchResultsVC = searchResults.popoverPresentationController
        searchResultsVC?.permittedArrowDirections = .up
        searchResultsVC?.delegate = self
        searchResultsVC?.sourceView = self.searchBar
        searchResultsVC?.sourceRect = self.searchBar.bounds
    }

}

// MARK: - Event Handlers
extension CourseAlertCreateController: ShowsAlert, CourseSearchDelegate {

    @objc fileprivate func handleCancel() {
        dismiss(animated: true, completion: nil)
    }

    @objc fileprivate func alertButton() {
        if let section = sectionToAlert {
            registerAlert(section: section)
        } else {
            CourseAlertNetworkManager.instance.getSearchedCourses(searchText: searchBar.text ?? "") { (results) in
                if let results = results {
                    if results.count == 1 {
                        self.sectionToAlert = results[0]
                        self.registerAlert(section: results[0])
                    } else {
                        DispatchQueue.main.async {
                            self.showAlert(withMsg: "Please select a valid course to create an alert.", title: "Invalid Course Selected", completion: nil)
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        self.showAlert(withMsg: "Please select a valid course to create an alert.", title: "Invalid Course Selected", completion: nil)
                    }
                }
            }

        }
    }

    fileprivate func registerAlert(section: CourseSection) {
        CourseAlertNetworkManager.instance.createRegistration(section: section.section, autoResubscribe: alertSwitch.isOn, callback: {(success, response, _) in
            DispatchQueue.main.async {
                if success {
                    self.showAlert(withMsg: response, title: "Success!", completion: self.handleCancel)
                    self.delegate?.fetchAlerts()
                } else if !response.isEmpty {
                    self.showAlert(withMsg: response, title: "Uh-Oh!", completion: nil)
                }
            }
        })
    }

    func selectSection(section: CourseSection) {
        sectionToAlert = section
        self.searchBar.text = section.section
        self.hideResultsPopover()
        self.searchBar.resignFirstResponder()
    }

}

// MARK: - Popover Functions
extension CourseAlertCreateController: UIPopoverPresentationControllerDelegate {

    @objc func handleSearchQuery() {
        let searchText = searchBar.text ?? ""
        print(searchText)
        if searchText.count >= 3 {
            CourseAlertNetworkManager.instance.getSearchedCourses(searchText: searchText) { (results) in
                if let results = results {
                    if results.count > 0 {
                        DispatchQueue.main.async {
                            self.searchResults.updateWithResults(results: results)
                            let searchResultsVC = self.searchResults.popoverPresentationController
                            searchResultsVC?.permittedArrowDirections = .up
                            searchResultsVC?.delegate = self
                            searchResultsVC?.sourceView = self.searchBar
                            searchResultsVC?.sourceRect = self.searchBar.bounds
                            if !self.searchResults.isVisible && !self.searchResults.isBeingPresented {
                                self.present(self.searchResults, animated: true, completion: nil)
                            }
                        }
                    } else {
                        self.hideResultsPopover()
                        self.searchResults.updateWithResults(results: [])
                    }
                } else {
                    self.hideResultsPopover()
                    self.searchResults.updateWithResults(results: [])
                }
            }
        } else {
            self.showAlert(withMsg: "Please enter at least 3 or more characters.", title: "Invalid Search", completion: nil)
            self.hideResultsPopover()
            self.searchResults.updateWithResults(results: [])
        }

    }

    func hideResultsPopover() {
        DispatchQueue.main.async {
            if self.searchResults.isVisible && !self.searchResults.isBeingDismissed {
                self.searchResults.dismiss(animated: true, completion: nil)
            }
        }
    }

    func prepareForPopoverPresentation(_ popoverPresentationController: UIPopoverPresentationController) {
        popoverPresentationController.delegate = self
    }

    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }

    func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {
        self.searchBar.resignFirstResponder()
    }

}

// MARK: - Search Bar Functions
extension CourseAlertCreateController: UISearchBarDelegate {

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        sectionToAlert = nil
        self.hideResultsPopover()
    }

    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.hideResultsPopover()
    }

    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        self.hideResultsPopover()
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        handleSearchQuery()
    }

}
