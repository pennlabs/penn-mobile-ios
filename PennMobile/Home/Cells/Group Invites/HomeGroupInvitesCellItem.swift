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
    static var jsonKey = "invites"
    static var associatedCell: ModularTableViewCell.Type = HomeGroupInvitesCell.self

    var invites: GSRGroupInvites

    init(for invites: GSRGroupInvites) {
        self.invites = invites
    }

    static func getHomeCellItem(_ completion: @escaping (([HomeCellItem]) -> Void)) {
        completion([])
    }

    func equals(item: ModularTableViewItem) -> Bool {
        guard let item = item as? HomeGroupInvitesCellItem else {return false}
        return invites.count == item.invites.count
    }
}
