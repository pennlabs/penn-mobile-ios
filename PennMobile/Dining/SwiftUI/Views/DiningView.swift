//
//  DiningView.swift
//  PennMobile
//
//  Created by CHOI Jongmin on 4/6/2020.
//  Copyright © 2020 PennLabs. All rights reserved.
//

import SwiftUI
#if canImport(SwiftUI)
import SwiftUI
#endif

@available(iOS 13.0.0, *)
struct DiningView: View {
    
    @State var pickerIndex = 0
    let viewsTitles = ["Locations", "Balance"]
    @State var alert = false
    
    @State var showBanner:Bool = true
    
    @ObservedObject var diningVM = DiningViewModelSwiftUI.instance
    
    var body: some View {
        let presentingAlert = Binding<Bool>(
            get: { self.diningVM.presentAlert },
            set: { value in print(value); self.diningVM.presentAlert = value}
        )
        
        return VStack {
            DiningViewHeader()
                .padding([.leading, .trailing])
            
            Picker(selection: self.$pickerIndex, label: Text("Please choose which view you would like to see")) {
                ForEach(0 ..< self.viewsTitles.count) {
                    Text(self.viewsTitles[$0])
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding([.leading, .trailing])
            
            if (self.pickerIndex == 0) {
                DiningVenueView().environmentObject(diningVM)
            } else {
                DiningInsightsView(pickerIndex: self.$pickerIndex).environmentObject(diningVM)
            }
            
            Spacer()
        }
        .padding(.top)
        .alert(type: diningVM.alertType, show: presentingAlert)
        .onAppear(perform: {
            UITableView.appearance().separatorStyle = .none
        })
    }
}

@available(iOS 13, *)
struct DiningView_Previews: PreviewProvider {
    
    static var previews: some View {
        DiningView()
    }
}
