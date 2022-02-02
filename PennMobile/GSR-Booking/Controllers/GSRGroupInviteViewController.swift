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
    fileprivate var inViteUsersLabel: UILabel!
    fileprivate var searchBar: UISearchBar!
    fileprivate var sendInvitesButton: UIButton!
    fileprivate var tableView: UITableView!

    fileprivate let disabledBtnColor = UIColor(red:32/255.0, green:156/255.0, blue:238/255.0, alpha:0.5)
    fileprivate let enabledBtnColor = UIColor(red:32/255.0, green:156/255.0, blue:238/255.0, alpha:1)

    fileprivate var users = GSRInviteSearchResults()
    fileprivate var filteredUsers = GSRInviteSearchResults() {
        didSet {
            sendInvitesButton.isEnabled = !filteredUsers.isEmpty
            sendInvitesButton.backgroundColor = sendInvitesButton.isEnabled ? enabledBtnColor : disabledBtnColor
            print(sendInvitesButton.isEnabled)
            print(filteredUsers)
        }
    }

    fileprivate var isSearchBarEmpty: Bool {
      return searchBar.text?.isEmpty ?? true
    }

    fileprivate var isFiltering: Bool {
      return !isSearchBarEmpty
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        prepareUI()

        GSRGroupNetworkManager.instance.getAllUsers { (success, results) in
            if (success) {
                self.users = results!

                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }

    func prepareCloseButton() {
        closeButton = UIButton()
        view.addSubview(closeButton)

        closeButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 40).isActive = true
        closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16).isActive = true
        closeButton.backgroundColor = UIColor(red: 118/255, green: 118/255, blue: 128/255, alpha: 12/100)
        closeButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        closeButton.widthAnchor.constraint(equalToConstant: 30).isActive = true
        closeButton.layer.cornerRadius = 15
        closeButton.layer.masksToBounds = false
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.setTitle("x", for: UIControl.State.normal)
        //closeButton.setImage(image: , for: UIControl.State.normal)
        closeButton.addTarget(self, action: #selector(cancelBtnAction), for: .touchUpInside)
    }

    func prepareInviteUsersLabel() {
        inViteUsersLabel = UILabel()
        inViteUsersLabel.text = "Invite Users"
        inViteUsersLabel.font = UIFont.boldSystemFont(ofSize: 24)
        view.addSubview(inViteUsersLabel)
        inViteUsersLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 14).isActive = true
        inViteUsersLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 79.5).isActive = true
        inViteUsersLabel.translatesAutoresizingMaskIntoConstraints = false
    }

    @objc func cancelBtnAction(sender:UIButton!) {
        dismiss(animated: true, completion:nil)
    }

    func prepareSearchBar() {
        searchBar = UISearchBar()
        searchBar.delegate = self
        searchBar.searchTextField.placeholder = "Search by Name or PennKey"
        searchBar.searchTextField.textColor = .black
        view.addSubview(searchBar)
        searchBar.topAnchor.constraint(equalTo: inViteUsersLabel.bottomAnchor, constant: 20).isActive = true
        searchBar.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        searchBar.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        searchBar.translatesAutoresizingMaskIntoConstraints = false
    }

    func prepareSendInvitationButton() {
        sendInvitesButton = UIButton()
        sendInvitesButton.backgroundColor = UIColor(red:32/255.0, green:156/255.0, blue:238/255.0, alpha:0.5)
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
//        sendInvitesButton.isUserInteractionEnabled = false
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

        return users.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        let user: GSRInviteSearchResult
        if isFiltering {
          user = filteredUsers[indexPath.row]
        } else {
          user = users[indexPath.row]
        }
        cell.textLabel?.text = user.username
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) else { return }

        if cell.accessoryType == UITableViewCell.AccessoryType.checkmark {
            cell.accessoryType = .none
            filteredUsers = filteredUsers.filter {$0 != users[indexPath.row]}
        } else {
            cell.accessoryType = .checkmark
            filteredUsers.append(users[indexPath.row])
        }

        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension GSRGroupInviteViewController {
    func filterContentForSearchText(_ searchText: String) {
      filteredUsers = users.filter { (user: GSRInviteSearchResult) -> Bool in
        return user.username.lowercased().contains(searchText.lowercased())
      }

      tableView.reloadData()
    }
}

extension GSRGroupInviteViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filterContentForSearchText(searchText)
    }
}

extension GSRGroupInviteViewController {
    @objc func didPressInviteBtn(sender: UIButton!) {
        print(filteredUsers)
    }
}
