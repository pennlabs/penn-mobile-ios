//
//  GSRGroupViewModel.swift
//  PennMobile
//
//  Created by Rehaan Furniturewala on 10/20/19.
//  Copyright © 2019 PennLabs. All rights reserved.
//

import Foundation

protocol GSRManageGroupViewModelDelegate {
    //TODO: Add stuff here
}



class GSRManageGroupViewModel: NSObject {
    //store important data used by gsr group views
    fileprivate var group: GSRGroup!
    fileprivate var settings = [String:String]() //todo change type of settings
    
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
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return settings.count
        } else {
            
            if let members = group.members {
                return members.count
            } else {
                return 0
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Settings"
        } else {
            return "Members"
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: GroupSettingsCell.identifier, for: indexPath) as! GroupSettingsCell
            cell.settings = group.userSettings
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: GroupMemberCell.identifier, for: indexPath) as! GroupMemberCell
            if let members = group.members {
                cell.member = members[indexPath.row]
            }
            return cell
        }
    }
    
    
}

//MARK: UITableViewDelegate
extension GSRManageGroupViewModel: UITableViewDelegate {
    
}
