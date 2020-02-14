//
//  GSRGroupInviteViewController.swift
//  PennMobile
//
//  Created by Lucy Yuewei Yuan on 11/3/19.
//  Copyright © 2019 PennLabs. All rights reserved.
//
//Users/lucyyyw/Desktop/pennlabs/penn-mobile-ios/PennMobile/GSR-Booking/Controllers/GSRLocationsController.swift
import UIKit

class GSRGroupInviteViewController: UIViewController {
    
    fileprivate var dummyLabel: UILabel!
    fileprivate var closeButton: UIButton!
    fileprivate var inviteUsersLabel: UILabel!
    fileprivate var searchBar: UISearchBar!
    fileprivate var sendInvitesButton: UIButton!
    fileprivate var tableView: UITableView!
    
    fileprivate let disabledBtnColor = UIColor.baseLabsBlue.withAlphaComponent(0.5)
    fileprivate let enabledBtnColor = UIColor.baseLabsBlue
    
    
    fileprivate var users = GSRInviteSearchResults()
    fileprivate var filteredUsers = GSRInviteSearchResults()
    
    var groupMembers: [GSRGroupMember]?
    
    fileprivate var selectedUsers = GSRInviteSearchResults() {
        didSet {
            self.selectedUsers.sort()
            
            DispatchQueue.main.async {
                self.sendInvitesButton.isEnabled = !self.selectedUsers.isEmpty
                self.sendInvitesButton.backgroundColor = self.sendInvitesButton.isEnabled ? self.enabledBtnColor : self.disabledBtnColor
            }
        }
    }
    fileprivate var loadingView: UIActivityIndicatorView!
    
    fileprivate var isSearchBarEmpty: Bool {
      return searchBar.text?.isEmpty ?? true
    }
    
    fileprivate var isFiltering: Bool {
      return !isSearchBarEmpty
    }
    
    fileprivate var debouncingTimer: Timer?
    
    var groupID: Int? //need to store id, so that we can send the invite request
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .uiBackground
        prepareUI()
    }
    
    func prepareCloseButton() {
        closeButton = UIButton()
        view.addSubview(closeButton)

        closeButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 25).isActive = true
        closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16).isActive = true
        closeButton.backgroundColor = UIColor(red: 118/255, green: 118/255, blue: 128/255, alpha: 12/100)
        closeButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        closeButton.widthAnchor.constraint(equalToConstant: 30).isActive = true
        closeButton.layer.cornerRadius = 15
        closeButton.layer.masksToBounds = false
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.setTitle("X", for: UIControl.State.normal)
        closeButton.addTarget(self, action: #selector(cancelBtnAction), for: .touchUpInside)
    }
    
    func prepareInviteUsersLabel() {
        inviteUsersLabel = UILabel()
        inviteUsersLabel.text = "Invite Users"
        inviteUsersLabel.font = UIFont.boldSystemFont(ofSize: 24)
        view.addSubview(inviteUsersLabel)
        inviteUsersLabel.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 14).isActive = true
        inviteUsersLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30).isActive = true
        inviteUsersLabel.translatesAutoresizingMaskIntoConstraints = false
    }
    
    @objc func cancelBtnAction(sender:UIButton!) {
        dismiss(animated: true, completion:nil)
    }
    
    func prepareSearchBar() {
        searchBar = UISearchBar()
        searchBar.delegate = self
        searchBar.searchTextField.placeholder = "Search by Name or PennKey"
        searchBar.searchTextField.textColor = .labelPrimary
        searchBar.searchTextField.autocapitalizationType = .none
        view.addSubview(searchBar)
        searchBar.topAnchor.constraint(equalTo: inviteUsersLabel.bottomAnchor, constant: 20).isActive = true
        searchBar.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        searchBar.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        searchBar.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func prepareSendInvitationButton() {
        sendInvitesButton = UIButton()
        sendInvitesButton.backgroundColor = UIColor.baseLabsBlue.withAlphaComponent(0.5)
        sendInvitesButton.setTitle("Send Invites", for: .normal)
        sendInvitesButton.setTitleColor(UIColor.white, for: .normal)
        sendInvitesButton.titleLabel?.font =  UIFont.boldSystemFont(ofSize: 17)
        sendInvitesButton.layer.cornerRadius = 8
        sendInvitesButton.layer.masksToBounds = true
        
        view.addSubview(sendInvitesButton)
        sendInvitesButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0).isActive = true
        sendInvitesButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 14).isActive = true
        sendInvitesButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -14).isActive = true
        sendInvitesButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        sendInvitesButton.translatesAutoresizingMaskIntoConstraints = false
        
        sendInvitesButton.addTarget(self, action: #selector(didPressInviteBtn), for: .touchUpInside)
        
        sendInvitesButton.isEnabled = false
    }
    
    func prepareTableView() {
        tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: sendInvitesButton.topAnchor, constant: -10).isActive = true
    }
}

//Mark: Setup UI
extension GSRGroupInviteViewController {
    fileprivate func prepareUI() {
        prepareCloseButton()
        prepareInviteUsersLabel()
        prepareSearchBar()
        prepareSendInvitationButton()
        prepareTableView()
        prepareLoadingView()
    }
}

extension GSRGroupInviteViewController: UITableViewDelegate {
    
}

extension GSRGroupInviteViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering {
            return filteredUsers.count
        }
        
        return selectedUsers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "resultscell")
        let user: GSRInviteSearchResult
        
        if isFiltering {
            user = filteredUsers[indexPath.row]
            cell.accessoryType = selectedUsers.contains(user) ? .checkmark : .none

            let isMember = groupMembers?.contains(where: { (groupMember) -> Bool in
                return groupMember.pennKey == user.pennkey
            }) ?? false
                
            // Selection style is used to detect if cell is an existing group member or not - check didSelectRowAt()
            cell.selectionStyle = isMember ? UITableViewCell.SelectionStyle.none : UITableViewCell.SelectionStyle.default
            cell.textLabel?.textColor = isMember ? .labelSecondary : .labelPrimary
            cell.detailTextLabel?.textColor = isMember ? .labelSecondary : .labelPrimary
            
        } else {
            user = selectedUsers[indexPath.row]
            cell.accessoryType = .checkmark
        }
        
        cell.detailTextLabel?.text = user.pennkey
        cell.textLabel?.text = "\(user.first ?? "") \(user.last ?? "")"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        
        // if cell for existing group member selected, do nothing
        guard cell.selectionStyle != UITableViewCell.SelectionStyle.none else { return }
        
        if cell.accessoryType == UITableViewCell.AccessoryType.checkmark {
            cell.accessoryType = .none
            
            if isFiltering {
                selectedUsers = selectedUsers.filter {$0 != filteredUsers[indexPath.row]}
            } else {
                selectedUsers = selectedUsers.filter {$0 != selectedUsers[indexPath.row]}
            }
        } else {
            cell.accessoryType = .checkmark
            selectedUsers.append(filteredUsers[indexPath.row])
        }
        print(selectedUsers)
        searchBar.text = ""
        
        tableView.reloadData()
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension GSRGroupInviteViewController {
    func filterContentForSearchText(_ searchText: String) {
        debouncingTimer?.invalidate()
        debouncingTimer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false, block: { (_) in
            GSRGroupNetworkManager.instance.getSearchResults(searchText: searchText) { (results) in
                if let results = results {
                    self.filteredUsers = results
                }
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        })
            
        
    }
}

extension GSRGroupInviteViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filterContentForSearchText(searchText)
    }
}

extension GSRGroupInviteViewController {
    @objc func didPressInviteBtn(sender: UIButton!) {
        startLoadingViewAnimation()
        let pennkeys = selectedUsers.map({$0.pennkey})
        if let groupID = groupID {
            GSRGroupNetworkManager.instance.inviteUsers(groupID: groupID, pennkeys: pennkeys, callback: {(success, error) in
                DispatchQueue.main.async {
                    self.stopLoadingViewAnimation()
        
                    if error != nil {
                        let alert = UIAlertController(title: "Error sending invites", message: "An unexpected error occured. Please try again later.", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    } else {
                        self.dismiss(animated: true, completion: nil)
                    }
                }
            })
        }
    }
}

extension GSRGroupInviteViewController {
    func prepareLoadingView() {
        loadingView = UIActivityIndicatorView(style: .whiteLarge)
        loadingView.color = .black
        loadingView.isHidden = true
    
        view.addSubview(loadingView)
        loadingView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loadingView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        loadingView.translatesAutoresizingMaskIntoConstraints = false
    }

    func startLoadingViewAnimation() {
        self.loadingView.isHidden = false
        self.loadingView.startAnimating()
    }

    func stopLoadingViewAnimation() {
        self.loadingView.isHidden = true
        self.loadingView.stopAnimating()
    }
}
