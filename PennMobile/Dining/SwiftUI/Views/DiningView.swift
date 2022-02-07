//
//  DiningView.swift
//  PennMobile
//
//  Created by CHOI Jongmin on 4/6/2020.
//  Copyright © 2020 PennLabs. All rights reserved.
//

import SwiftUI

@available(iOS 14, *)
struct DiningView: View {
    @StateObject var diningVM = DiningViewModelSwiftUI.instance

    var body: some View {
        return
                DiningVenueView()
                    .environmentObject(diningVM)
    }
}

@available(iOS 14, *)
struct DiningView_Previews: PreviewProvider {
    static var previews: some View {
        DiningView()
    }
}
