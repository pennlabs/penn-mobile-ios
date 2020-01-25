//
//  GSRGroupViewModel.swift
//  PennMobile
//
//  Created by Rehaan Furniturewala on 10/20/19.
//  Copyright © 2019 PennLabs. All rights reserved.
//

import Foundation

protocol GSRManageGroupViewModelDelegate {
    func beginBooking()
    func inviteToGroup()
}

protocol GroupManageButtonDelegate {
    func bookGroup()
    func inviteGroup()
    func leaveGroup()
}

protocol GSRGroupIndividualSettingDelegate {
    func updateSetting(setting: GSRGroupIndividualSetting)
}

class GSRManageGroupViewModel: NSObject {
    //store important data used by gsr group views
    fileprivate var group: GSRGroup!

    // MARK: Delegate
    var delegate: GSRManageGroupViewModelDelegate!

    // MARK: init
    init(group: GSRGroup) {
        self.group = group
    }

    func setGroup(group: GSRGroup) {
        self.group = group
    }
}

//MARK: UITableViewDataSource
extension GSRManageGroupViewModel: UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 1:
            return 35
        default:
            return 0
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 3
        } else if section == 1 {
            if let members = group.members {
                return members.count
            } else {
                return 0
            }
        } else {
            return 1
        }
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 1 {
            return "Members"
        } else {
            return " " //DO NOT REMOVE, otherwise extra space will appear
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: GroupHeaderCell.identifier, for: indexPath) as! GroupHeaderCell
                cell.groupTitle = group.name
                let color = group.parseColor() ??  UIColor(named: "blueLighter")
                cell.groupColor = color

                if let members = group.members {
                    cell.memberCount = members.count
                }

                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: GroupSettingsCell.identifier, for: indexPath) as! GroupSettingsCell
                if let userSettings = group.userSettings {
                    let userSetting = indexPath.row == 1 ? userSettings.pennKeyActive : userSettings.notificationsOn
                    cell.setupCell(with: userSetting)
                    cell.delegate = self
                }
                
                return cell
            }

        } else if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: GroupMemberCell.identifier, for: indexPath) as! GroupMemberCell
            if let members = group.members {
                cell.member = members[indexPath.row]
            }
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: GroupManageButtonCell.identifier) as! GroupManageButtonCell
            cell.delegate = self
            return cell
        }
    }

    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if indexPath.section == 0 {
            return nil
        }

        return nil
    }
    


}

//MARK: UITableViewDelegate
extension GSRManageGroupViewModel: UITableViewDelegate {

}

//MARK: GSRGroupIndividualSettingDelegate
extension GSRManageGroupViewModel: GSRGroupIndividualSettingDelegate {
    func updateSetting(setting: GSRGroupIndividualSetting) {
        print("Update Setting \(setting.title) to \(setting.isEnabled)")
        // TODO - call the GSRGroupNetworkManager to change setting
    }
}

extension GSRManageGroupViewModel: GroupManageButtonDelegate {
    func bookGroup() {
        delegate.beginBooking()
    }
    
    func inviteGroup() {
        delegate.inviteToGroup()
        print("Share Group!")
    }
    
    func leaveGroup() {
        print("Leave Group!")
    }
}