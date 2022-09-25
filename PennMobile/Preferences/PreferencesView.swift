//
//  PreferencesView.swift
//  PennMobile
//
//  Created by Raunaq Singh on 9/18/22.
//  Copyright © 2022 PennLabs. All rights reserved.
//

import SwiftUI

struct PreferencesView: View {
    var body: some View {
        VStack(alignment: .leading) {
            Button("Update tabs!") {
                setTabPreferences(tabPreferences: [.dining, .studyRoomBooking, .laundry])
            }
        }
    }
}

extension PreferencesView {
    func setTabPreferences(tabPreferences: [Feature]) {
        UserDefaults.standard.setTabPreferences([.home] + tabPreferences + [.more])
    }
}

struct PreferencesView_Previews: PreviewProvider {
    static var previews: some View {
        PreferencesView()
    }
}
