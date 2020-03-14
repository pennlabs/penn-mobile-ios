//
//  GSRGroupConfirmBookingViewModel.swift
//  PennMobile
//
//  Created by Rehaan Furniturewala on 3/13/20.
//  Copyright © 2020 PennLabs. All rights reserved.
//

import UIKit

class GSRGroupConfirmBookingViewModel: NSObject {
    fileprivate var groupBooking: GSRGroupBooking!
    init(groupBooking: GSRGroupBooking) {
        self.groupBooking = groupBooking
    }
}

// MARK: - UITableViewDataSource
extension GSRGroupConfirmBookingViewModel: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groupBooking.bookings.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: GroupBookingConfirmationCell.identifier) as! GroupBookingConfirmationCell
        cell.booking = groupBooking.bookings[indexPath.row]
        return cell
    }
    
}

// MARK: - UITableViewDelegate
extension GSRGroupConfirmBookingViewModel: UITableViewDelegate {
    
}

