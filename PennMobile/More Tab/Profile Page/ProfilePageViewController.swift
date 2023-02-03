//
//  AccountPageViewController.swift
//  PennMobile
//
//  Created by Andrew Antenberg on 9/26/21.
//  Copyright © 2021 PennLabs. All rights reserved.
//

import Foundation
import UIKit

class ProfilePageViewController: UIViewController, ShowsAlertForError {
    var account: Account!
    let tableView = UITableView(frame: .zero, style: .insetGrouped)
    let picker = UIImagePickerController()
    var viewModel: ProfilePageViewModel!

    var profileInfo: [(text: String, info: String)] = []
    var educationInfo: [(text: String, info: String)] = []
    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        guard Account.isLoggedIn else {
            self.showAlert(withMsg: "Please login to use this feature", title: "Login Error", completion: { self.navigationController?.popViewController(animated: true)})
            return
        }
        setupPickerController()
        setupViewModel()
        setupTableView()
    }

    func setupPickerController() {
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true

    }

    func setupViewModel() {
        viewModel = ProfilePageViewModel()
        tableView.delegate = viewModel
        tableView.dataSource = viewModel
        picker.delegate = viewModel

        viewModel.delegate = self
    }

    func setupView() {
        self.title = "Account"
        view.backgroundColor = .uiGroupedBackground
    }
    func setupTableView() {
        view.addSubview(tableView)
        tableView.register(ProfilePageTableViewCell.self, forCellReuseIdentifier: ProfilePageTableViewCell.identifier)
        tableView.register(ProfilePictureTableViewCell.self, forCellReuseIdentifier: ProfilePictureTableViewCell.identifier)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true

        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 600
    }
}

extension ProfilePageViewController: ProfilePageViewModelDelegate {
    func presentImagePicker() {
        present(picker, animated: true)
    }
    func presentTableView(isMajors: Bool) {
        let targetController = InfoTableViewController()
        targetController.isMajors = isMajors
        navigationController?.pushViewController(targetController, animated: true)
    }
    func imageSelected(_ image: UIImage) {
        if let cell = tableView.cellForRow(at: .init(row: 0, section: 0)) as? ProfilePictureTableViewCell {
            cell.profilePicImage = image
            // TODO: Find a better place to put this
            Task {
                guard let imageData = image.jpegData(compressionQuality: 0.5) else {
                    return
                }
                
                guard let token = await OAuth2NetworkManager.instance.getAccessToken() else {
                    return
                }
                
                let url = URL(string: "https://platform.pennlabs.org/accounts/me")!
                // TODO: Break this out into a separate utility
                let csrfToken: String
                if let cookie = HTTPCookieStorage.shared.cookies(for: url)?.first(where: { $0.name == "csrftoken" }) {
                    csrfToken = cookie.value
                } else {
                    // TODO: Get a new CSRF token
                    return
                }

                var request = URLRequest(url: URL(string: "https://platform.pennlabs.org/accounts/me")!, accessToken: token)
                let boundary = "---------------------------------thisboundarybetternotappearinanyonesimagedata"
                request.addValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
                request.addValue(csrfToken, forHTTPHeaderField: "X-CSRFToken")
                request.httpMethod = "PATCH"
                
                var requestData = Data()
                requestData.append("\(boundary)\r\n".data(using: .utf8)!)
                requestData.append("Content-Type: image/jpeg\r\n".data(using: .utf8)!)
                requestData.append("Content-Disposition: form-data; name=profile_pic\r\n".data(using: .utf8)!)
                requestData.append("\r\n".data(using: .utf8)!)
                print(String(data: requestData, encoding: .utf8)!)
                requestData.append(imageData)
                request.httpBody = requestData
                
                let response: URLResponse
                let responseData: Data

                do {
                    (responseData, response) = try await URLSession.shared.data(for: request)
                } catch let error {
                    // TODO: Make good
                    print(error)
                    return
                }
                
                print(response)
                print(String(data: responseData, encoding: .utf8) ?? "(invalid data)")
            }
        }
    }
}
