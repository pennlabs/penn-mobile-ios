//
//  HomeGroupInvitesCellItem.swift
//  PennMobile
//
//  Created by Daniel Salib on 2/7/20.
//  Copyright © 2020 PennLabs. All rights reserved.
//

import Foundation
import SwiftyJSON

final class HomeGroupInvitesCellItem: HomeCellItem {
    static var associatedCell: ModularTableViewCell.Type {
        return HomeGroupInvitesCell.self
    }
    
    var invites: GSRGroupInvites
    
    init(invites: GSRGroupInvites) {
        self.invites = invites
    }
    
    func equals(item: ModularTableViewItem) -> Bool {
        guard let item = item as? HomeGroupInvitesCellItem else {return false}
        return invites.count == item.invites.count
    }
    
    static var jsonKey: String {
        return "invites"
    }
    
    static func getItem(for json: JSON?) -> HomeCellItem? {
        // comment out following line once server is updated to show cell
//        guard let json = json else { return nil }
        return HomeGroupInvitesCellItem(invites: GSRGroupInvites())
    }
}

extension HomeGroupInvitesCellItem: HomeAPIRequestable {
    func fetchData(_ completion: @escaping () -> Void) {
        GSRGroupNetworkManager.instance.getInvites { (success, invites, error) in
            if success {
                self.invites = invites
            }

            completion()
        }
    }
}
