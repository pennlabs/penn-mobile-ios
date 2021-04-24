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
    
    let viewsTitles = ["Locations", "Balance"]
    
    @State var pickerIndex = 0
    @State var alert = false
    
    // iOS14, guarantees that DiningViewModel will not be destroyed and exists when body property is ran
    @StateObject var diningVM = DiningViewModelSwiftUI.instance
    
    var body: some View {
        let alertType = Binding<NetworkingError?>(
            get: { self.diningVM.alertType },
            set: { value in self.diningVM.alertType = value}
        )
        
        return VStack {
            DiningViewHeader()
                .environmentObject(diningVM)
                .padding(.horizontal)

            #if DEBUG
//            Picker(selection: self.$pickerIndex, label: Text("Please choose which view you would like to see")) {
//                ForEach(0 ..< self.viewsTitles.count) {
//                    Text(self.viewsTitles[$0])
//                }
//            }
//            .pickerStyle(SegmentedPickerStyle())
//            .padding(.horizontal)
//            if (self.pickerIndex == 0) {
            DiningVenueView()
                .environmentObject(diningVM)
                    
//            } else {
//                if UserDefaults.standard.hasDiningPlan() {
//                    DiningInsightsView(pickerIndex: self.$pickerIndex).environmentObject(diningVM)
//                } else {
//                    Rectangle()
//                        .foregroundColor(.white)
//                        .frame(width:100, height: 100)
//                        .onTapGesture(perform: {
//                            alert = true
//                        })
//                }
//            }
            #else
                DiningVenueView()
                    .environmentObject(diningVM)
            #endif
        }
        .padding(.top)
        .alert(show: alertType)
    }
}

@available(iOS 14, *)
struct DiningView_Previews: PreviewProvider {
    static var previews: some View {
        DiningView()
    }
}
