//
//  DiningView.swift
//  PennMobile
//
//  Created by CHOI Jongmin on 4/6/2020.
//  Copyright © 2020 PennLabs. All rights reserved.
//

#if canImport(SwiftUI)
import SwiftUI
#endif

@available(iOS 14, *)
struct DiningView: View {
    @StateObject var diningVM = DiningViewModelSwiftUI()
    
    var body: some View {
        return
            VStack(spacing: 0) {
                DiningViewHeader()
                    .padding()
                
                DiningVenueView()
            }
            .environmentObject(diningVM)
    }
}

@available(iOS 14, *)
struct DiningView_Previews: PreviewProvider {
    static var previews: some View {
        DiningView()
    }
}
