//
//  ProfilePageViewModel.swift
//  PennMobile
//
//  Created by Andrew Antenberg on 10/10/21.
//  Copyright © 2021 PennLabs. All rights reserved.
//

import Foundation
import UIKit

protocol ProfilePageViewModelDelegate {
    func presentImagePicker()
    func presentTableView(isMajors: Bool)
    func imageSelected(_ image: UIImage)
}

class ProfilePageViewModel: NSObject {
    // isLoggedIn() that is run is ProfilePageViewController checks that Account.getAccount != nil
    var account = Account.getAccount()!
    var profileInfo: [(text: String, info: String)] = []
    var educationInfo: [(text: String, info: String)] = []
    var delegate: ProfilePageViewModelDelegate!

    override init() {
        super.init()
        setupProfileInfo()
        setupEducationInfo()
        fetchAccount()
    }

    func fetchAccount() {
        OAuth2NetworkManager.instance.getAccessToken { (token) in
            guard let token = token else {
                return
            }

            OAuth2NetworkManager.instance.retrieveAccount(accessToken: token, {(account) in
                if let account = account {
                    Account.saveAccount(account)
                    self.account = account
                    self.setupProfileInfo()
                    self.setupEducationInfo()
                    DispatchQueue.main.async {
                        (self.delegate as? ProfilePageViewController)?.tableView.reloadData()
                    }
                }
            })
        }
    }

    func setupProfileInfo() {
        profileInfo = []
        profileInfo.append((text: "Username", info: account.username))

        guard let email = account.email else {
            return
        }
        profileInfo.append((text: "Email", info: email))
    }

    func setupEducationInfo() {
        educationInfo = []
        let majorsSet = account.student.major.map({ $0.name })
        let schoolsSet = account.student.school.map({ $0.name })

        var gradTerm = ""
        if let graduationYear = account.student.graduationYear {
            gradTerm = String(graduationYear)
        }

        educationInfo.append((text: "Graduation Year", info: gradTerm))
        educationInfo.append((text: "School", info: Array(schoolsSet).joined(separator: ", ")))
        educationInfo.append((text: "Major", info: Array(majorsSet).joined(separator: ", ")))
        if schoolsSet.count > 1 {
            educationInfo[1].text += "s"
        }

        if majorsSet.count > 1 {
            educationInfo[2].text += "s"
        }
    }

}

extension ProfilePageViewModel: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1 + profileInfo.count
        } else {
            return educationInfo.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: ProfilePictureTableViewCell.identifier, for: indexPath) as! ProfilePictureTableViewCell
                cell.account = account
//                cell.accessoryType = .disclosureIndicator
                cell.selectionStyle = .none
                return cell
            }
            let cell = tableView.dequeueReusableCell(withIdentifier: ProfilePageTableViewCell.identifier, for: indexPath) as! ProfilePageTableViewCell
            cell.key = profileInfo[indexPath.row-1].text
            cell.info = profileInfo[indexPath.row-1].info
            cell.selectionStyle = .none
            cell.accessoryType = .none
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: ProfilePageTableViewCell.identifier, for: indexPath) as! ProfilePageTableViewCell
            cell.key = educationInfo[indexPath.row].text
            cell.info = educationInfo[indexPath.row].info
            if indexPath.row > 0 {
//                cell.accessoryType = .disclosureIndicator
                cell.selectionStyle = .default
                cell.selectionStyle = .none
            } else {
                cell.selectionStyle = .none
                cell.accessoryType = .none
            }
            return cell
        }
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        2
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "PROFILE"
        }
        return "EDUCATION"
    }

    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if section == 0 {
            return "If your information is incorrect, please send an email to contact@pennlabs.org detailing your issue."
        }
        return nil
    }

//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        tableView.deselectRow(at: indexPath, animated: true)
//        if indexPath.row == 0 && indexPath.section == 0 {
//            delegate.presentImagePicker()
//        }
//        if indexPath.row == 1 && indexPath.section == 1 {
//            delegate.presentTableView(isMajors: false)
//        }
//        if indexPath.row == 2 && indexPath.section == 1 {
//            delegate.presentTableView(isMajors: true)
//        }
//    }

}

extension ProfilePageViewModel: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        guard let image = info[.editedImage] as? UIImage else { return }
        delegate.imageSelected(image)
        picker.dismiss(animated: true)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}
