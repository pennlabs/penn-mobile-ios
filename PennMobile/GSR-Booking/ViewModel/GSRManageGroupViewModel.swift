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
//    func kickFromGroup(member: GSRGroupMember)
    func handleSelectMember(member: GSRGroupMember)
    func fetchGroup()
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
    fileprivate var currentUser: GSRGroupMember!

    // MARK: Delegate
    var delegate: GSRManageGroupViewModelDelegate!

    // MARK: init
    init(group: GSRGroup) {
        self.group = group
    }

    func setGroup(_ group: GSRGroup) {
        self.group = group
        guard let pennkey = Account.getAccount()?.pennkey else { return }
        
        currentUser = group.members?.first(where: {$0.pennKey == pennkey})
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
        if group.members != nil {
            return 3
        }
        
        return 2
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
                cell.groupColor = group.color
                cell.selectionStyle = UITableViewCell.SelectionStyle.none

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
            
            cell.selectionStyle = UITableViewCell.SelectionStyle.gray
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: GroupManageButtonCell.identifier) as! GroupManageButtonCell
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            cell.delegate = self
            cell.isAdmin = currentUser?.isAdmin
            return cell
        }
    }

//    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
//        if indexPath.section == 0 {
//            return nil
//        }
//
//        return nil
//    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            if currentUser.isAdmin {
                delegate.handleSelectMember(member: group.members![indexPath.row])
            }
            
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    


}

//MARK: UITableViewDelegate
extension GSRManageGroupViewModel: UITableViewDelegate {

}

//MARK: GSRGroupIndividualSettingDelegate
extension GSRManageGroupViewModel: GSRGroupIndividualSettingDelegate {
    func updateSetting(setting: GSRGroupIndividualSetting) {
        GSRGroupNetworkManager.instance.updateIndividualSetting(groupID: group.id, settingType: setting.type, isEnabled: setting.isEnabled, callback: {(success, error) in
            if let error = error {
                print(error)
            } else {
                self.delegate.fetchGroup()
            }
        })
    }
}

extension GSRManageGroupViewModel: GroupManageButtonDelegate {
    func bookGroup() {
        delegate.beginBooking()
    }
    
    func inviteGroup() {
        delegate.inviteToGroup()
    }
    
    func leaveGroup() {
        print("Leave Group!")
    }
}
