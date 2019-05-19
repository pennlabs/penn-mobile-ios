//
//  HomeReservationsCellItem.swift
//  PennMobile
//
//  Created by Marta García Ferreiro on 3/17/19.
//  Copyright © 2019 PennLabs. All rights reserved.
//

import Foundation

final class HomeReservationsCellItem: HomeCellItem {
    static var associatedCell: ModularTableViewCell.Type {
        return HomeReservationsCell.self
    }
    
    var reservations: [GSRReservation]
    
    init(reservations: [GSRReservation]) {
        self.reservations = reservations
    }
    
    func equals(item: ModularTableViewItem) -> Bool {
        guard let item = item as? HomeReservationsCellItem else { return false }
        return reservations.count == item.reservations.count
    }
    
    static var jsonKey: String {
        return "reservations"
    }
    
    static func getItem(for json: JSON?) -> HomeCellItem? {
        guard let json = json else { return nil }
        do {
            let reservations = try GSRNetworkManager.instance.parseReservationsFromArray(json: json)
            return HomeReservationsCellItem(reservations: reservations)
        } catch {
            return nil
        }
    }
}
