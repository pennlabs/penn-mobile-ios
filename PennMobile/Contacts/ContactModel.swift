//
//  ContactModel.swift
//  PennMobile
//
//  Created by Jordan Hochman on 11/16/24.
//  Copyright © 2024 PennLabs. All rights reserved.
//

import Foundation

struct Contact: Identifiable {
    let name: String
    let contactName: String
    let phone: String
    let description: String?
    let phoneFiltered: String
    
    var id: String { name }
    
    init(name: String, contactName: String, phoneNumber: String, desc: String? = nil) {
        self.name = name
        self.phone = phoneNumber
        self.contactName = contactName
        self.description = desc
        self.phoneFiltered = phoneNumber.filter { $0.isNumber }
    }
}

extension Contact {
    static let pennGeneral = Contact(name: "Penn Police (Non-Emergency)", contactName: "Penn Police (Non-Emergency)", phoneNumber: "(215) 898-7297", desc: "Call for all non-emergencies.")
    
    static let pennEmergency = Contact(name: "Penn Police/MERT (Emergency)", contactName: "Penn Police/MERT (Emergency)", phoneNumber: "(215) 573-3333", desc: "Call for all criminal or medical emergencies.")
    
    static let pennWalk = Contact(name: "Penn Walk", contactName: "Penn Walk", phoneNumber: "215-898-WALK (9255)", desc: "Call for a walking escort between 30th and 43rd Streets and Market Street and Baltimore Avenue.")
    
    static let pennRide = Contact(name: "Penn Ride", contactName: "Penn Ride", phoneNumber: "215-898-RIDE (7433)", desc: "Call for Penn Ride services.")
    
    static let helpLine = Contact(name: "Help Line", contactName: "Penn Help Line", phoneNumber: "215-898-HELP (4357)", desc: "24-hour phone line for navigating Penn's health and wellness resources.")
    
    static let caps = Contact(name: "CAPS", contactName: "Penn CAPS", phoneNumber: "215-898-7021", desc: "Call anytime to reach Penn's Counseling and Psychological Services Center.")
    
    static let specialServices = Contact(name: "Special Services", contactName: "Penn Special Services", phoneNumber: "215-898-4481", desc: "Call to inquire or receive support services when victimized by any type of crime.")
    
    static let womensCenter = Contact(name: "Women's Center", contactName: "Penn Women's Center", phoneNumber: "215-898-8611", desc: "The Women's Center sponsors programs on career development, stress management, parenting, violence prevention, and more.")
    
    static let shs = Contact(name: "Student Health Services", contactName: "Penn Student Health Services", phoneNumber: "215-746-3535", desc: "Call to make an appointment, contact a department, or address urgent medical issues.")
    
    static let ofa = Contact(name: "Office of Affirmative Action", contactName: "Penn Office of Affirmative Action", phoneNumber: "(215) 898-6993", desc: "Call regarding issues related to the University's obligations as an aff. action and equal opp. employer and educational institution.")
    
    static let contacts = [pennEmergency, pennGeneral, pennWalk, pennRide, helpLine, caps, specialServices, womensCenter, shs, ofa]
}
