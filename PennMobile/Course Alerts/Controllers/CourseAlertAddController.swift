//
//  CourseAlertAddController.swift
//  PennMobile
//
//  Created by Raunaq Singh on 10/25/20.
//  Copyright © 2020 PennLabs. All rights reserved.
//

import UIKit
import Foundation

protocol FetchPCADataProtocol: class {
    func fetchAlerts()
    func fetchSettings()
}

class CourseAlertAddController: GenericViewController {
    
    fileprivate var searchBar = UISearchBar()
    fileprivate var alertSwitch: UISwitch!
    fileprivate var addButton: UIButton!
    fileprivate var switchLabel: UILabel!
    fileprivate var errorLabel: UILabel!
    
    fileprivate var navBar: UINavigationBar!
    
    fileprivate var searchResults: SearchResultsPopover!
    fileprivate var currentSearch = "" {
        didSet {
            NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(handleSearchQuery), object: nil)
            self.perform(#selector(handleSearchQuery), with: nil, afterDelay: 0.3)
        }
    }
    
    fileprivate var sectionToAlert: CourseSection?
    
    weak var delegate: FetchPCADataProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navBar = UINavigationBar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 44))
        view.addSubview(navBar)
        let navItem = UINavigationItem(title: "Add Course Alerts")
        navItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .done, target: self, action: #selector(handleCancel))
        navBar.setItems([navItem], animated: false)
        
        searchBar.delegate = self
                
        setupUI()
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
}

extension CourseAlertAddController: ShowsAlert {
    
    fileprivate func setupUI() {
        setupSearchBar()
        setupSwitchLabel()
        setupAlertSwitch()
        setupAddButton()
        setupResultsPopover()
        //setupErrorLabel()
    }
    
    fileprivate func setupSearchBar() {
        searchBar.placeholder = "Course"
        searchBar.returnKeyType = .done
        searchBar.autocapitalizationType = .allCharacters
        searchBar.autocorrectionType = .no
        searchBar.keyboardType = .asciiCapable
        
        searchBar.layer.borderWidth = 1
        searchBar.layer.borderColor = UIColor.white.cgColor
        
        view.addSubview(searchBar)
        
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.topAnchor.constraint(equalTo: navBar.bottomAnchor, constant: 75).isActive = true
        searchBar.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        searchBar.widthAnchor.constraint(equalToConstant: 300).isActive = true
        searchBar.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
    }

    fileprivate func setupSwitchLabel() {
        switchLabel = UILabel()
        switchLabel.text = "Alert me until I cancel."
        switchLabel.font = UIFont.interiorTitleFont
        switchLabel.textColor = .labelSecondary
        switchLabel.textAlignment = .center
        switchLabel.numberOfLines = 0
        switchLabel.sizeToFit()
        
        view.addSubview(switchLabel)
        
        switchLabel.translatesAutoresizingMaskIntoConstraints = false
        switchLabel.leadingAnchor.constraint(equalTo: searchBar.leadingAnchor, constant: -12).isActive = true
        switchLabel.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 20).isActive = true
        switchLabel.widthAnchor.constraint(equalToConstant: 220).isActive = true
    }
    
    fileprivate func setupAlertSwitch() {
        alertSwitch = UISwitch()
        alertSwitch.setOn(false, animated: false)
        alertSwitch.onTintColor = .blueLight
        
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
        addButton.backgroundColor = .blueLight
        addButton.layer.cornerRadius = 8
        addButton.addTarget(self, action: #selector(alertButton), for: .touchUpInside)
        
        view.addSubview(addButton)
        
        addButton.translatesAutoresizingMaskIntoConstraints = false
        addButton.topAnchor.constraint(equalTo: alertSwitch.bottomAnchor, constant: 40).isActive = true
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
        
        searchResults.setHeight()

    }
    
    fileprivate func setupErrorLabel() {
        errorLabel = UILabel()
        errorLabel.text = "Please select a valid course to create an alert."
        errorLabel.font = UIFont.interiorTitleFont
        errorLabel.textColor = .labelSecondary
        errorLabel.textAlignment = .center
        errorLabel.numberOfLines = 0
        errorLabel.sizeToFit()
        
        view.addSubview(errorLabel)
        
        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        errorLabel.leadingAnchor.constraint(equalTo: searchBar.leadingAnchor, constant: -12).isActive = true
        errorLabel.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 20).isActive = true
        errorLabel.widthAnchor.constraint(equalToConstant: 220).isActive = true
    }
    
    @objc fileprivate func handleCancel() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc fileprivate func alertButton() {
        if let section = sectionToAlert {
            registerAlert(section: section)
        } else {
            CourseAlertNetworkManager.instance.getSearchedCourses(searchText: currentSearch) { (results) in
                if let results = results {
                    if (results.count == 1) {
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
        CourseAlertNetworkManager.instance.createRegistration(section: section.section, autoResubscribe: alertSwitch.isOn, callback: {(success, response, error) in
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
    
}

extension CourseAlertAddController: UIPopoverPresentationControllerDelegate {
    
    @objc func handleSearchQuery() {
        if currentSearch.count >= 3 {
            CourseAlertNetworkManager.instance.getSearchedCourses(searchText: currentSearch) { (results) in
                if let results = results {
                    if (results.count > 0) {
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
                        self.searchResults.updateWithResults(results: [])
                        self.hideResultsPopover()
                    }
                } else {
                    self.searchResults.updateWithResults(results: [])
                    self.hideResultsPopover()
                }
            }
        } else {
            self.searchResults.updateWithResults(results: [])
            self.hideResultsPopover()
        }
        
    }
    
    func hideResultsPopover(){
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

extension CourseAlertAddController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        sectionToAlert = nil
        currentSearch = searchText
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        handleSearchQuery()
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        self.hideResultsPopover()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.hideResultsPopover()
        self.searchBar.resignFirstResponder()
    }
    
}

extension CourseAlertAddController: CourseSearchDelegate {
    
    func selectSection(section: CourseSection) {
        sectionToAlert = section
        self.searchBar.text = section.section
        self.hideResultsPopover()
        self.searchBar.resignFirstResponder()
    }
    
}
