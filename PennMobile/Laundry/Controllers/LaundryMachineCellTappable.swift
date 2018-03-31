//
//  LaundryMachineCellTappable.swift
//  PennMobile
//
//  Created by Josh Doman on 3/2/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//

import Foundation

protocol LaundryMachineCellTappable: NotificationRequestable {
    var allowMachineNotifications: Bool { get }
    func handleMachineCellTapped(for machine: LaundryMachine, _ updateCellIfNeeded: @escaping () -> Void) 
}

extension LaundryMachineCellTappable where Self: UIViewController {
    func handleMachineCellTapped(for machine: LaundryMachine, _ updateCellIfNeeded: @escaping () -> Void) {
        if !allowMachineNotifications { return }
        
        if machine.isUnderNotification() {
            LaundryNotificationCenter.shared.removeOutstandingNotification(for: machine)
            updateCellIfNeeded()
        } else {
            requestNotification { (granted) in
                if granted {
                    LaundryNotificationCenter.shared.notifyWithMessage(for: machine, title: "Ready!", message: "The \(machine.roomName) \(machine.isWasher ? "washer" : "dryer") has finished running.", completion: { (success) in
                        if success {
                            updateCellIfNeeded()
                        }
                    })
                    GoogleAnalyticsManager.shared.trackEvent(category: .laundry, action: .registerNotification, label: machine.roomName, value: 0)
                }
            }
        }
    }
}
