//
//  RootView.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 9/12/26.
//  Copyright © 2026 PennLabs. All rights reserved.
//

import SwiftUI
import LabsPlatformSwift
import PennMobileShared

struct RootView: View {
    @EnvironmentObject var platform: LabsPlatform
    
    var body: some View {
        if platform.isLoggedIn {
            CentralTabs()
        } else {
            LoggedOutView()
        }
    }
}
