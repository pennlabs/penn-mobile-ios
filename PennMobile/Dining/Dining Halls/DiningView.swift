//
//  DiningView.swift
//  PennMobile
//
//  Created by CHOI Jongmin on 4/6/2020.
//  Copyright © 2020 PennLabs. All rights reserved.
//

import SwiftUI

struct DiningView: View {
    @StateObject var diningVM = DiningViewModel.instance
    @Environment(\.presentToast) var presentToast

    var body: some View {
        return
                DiningVenueView()
                    .environmentObject(diningVM)
    }
}

struct DiningView_Previews: PreviewProvider {
    static var previews: some View {
        DiningView()
    }
}
