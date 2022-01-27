//
//  HomeReservationsCellItem.swift
//  PennMobile
//
//  Created by Marta García Ferreiro on 3/17/19.
//  Copyright © 2019 PennLabs. All rights reserved.
//

import Foundation
import SwiftyJSON

final class HomeReservationsCellItem: HomeCellItem {
    static var associatedCell: ModularTableViewCell.Type {
        return HomeReservationsCell.self
    }
    
    static func getHomeCellItem(_ completion: @escaping (([HomeCellItem]) -> Void)) {
        GSRNetworkManager.instance.getReservations { result in
            switch result {
            case .success(let reservations):
                if reservations.count > 0 {
                    completion([HomeReservationsCellItem(for: reservations)])
                } else {
                    completion([])
                }
            case .failure:
                completion([])
            }
        }
    }
    
    var reservations: [GSRReservation]
    
    init(for reservations: [GSRReservation]) {
        self.reservations = reservations
    }
    
    func equals(item: ModularTableViewItem) -> Bool {
        guard let item = item as? HomeReservationsCellItem else { return false }
        return reservations == item.reservations
    }
    
    static var jsonKey: String {
        return "reservations"
    }
}
