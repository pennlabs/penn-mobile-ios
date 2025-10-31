//
//  HomeViewAnnounceable.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 2/19/25.
//  Copyright © 2025 PennLabs. All rights reserved.
//

// We should be able to make a viewmodel provide items to display on the home screen should the need arise.
// This is similar to the Home Cells from previous iterations, just updated to SwiftUI
// The idea is that a ViewModel conforming to HomeViewAnnounceable provides an async function that returns
// HomeViewAnnouncement Models.
import SwiftUI

protocol HomeViewAnnounceable {
    func getHomeViewAnnouncements() async -> [HomeViewAnnouncement]
}
