//
//  HomeGroupInvitesCell.swift
//  PennMobile
//
//  Created by Daniel Salib on 2/7/20.
//  Copyright © 2020 PennLabs. All rights reserved.
//

import Foundation

final class HomeGroupInvitesCell: UITableViewCell, HomeCellConformable {
    var cardView: UIView!
    
    static var identifier: String {
        return "invitesCell"
    }
    
    static func getCellHeight(for item: ModularTableViewItem) -> CGFloat {
        return 20
    }
    
    var item: ModularTableViewItem!
    
    var delegate: ModularTableViewCellDelegate!
    
    
}
