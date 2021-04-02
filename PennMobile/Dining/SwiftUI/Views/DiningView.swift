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
    
    @State var pickerIndex = 0
    let viewsTitles = ["Locations", "Balance"]
    @State var alert = false
    
    @State var showBanner:Bool = true
    
    // iOS14, guarantees that DiningViewModel will not be destroyed and exists when body property is ran
    @StateObject var diningVM = DiningViewModelSwiftUI.instance
    
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
                DiningVenueView()
                    .environmentObject(diningVM)
            } else {
//                if UserDefaults.standard.hasDiningPlan() {
                    DiningInsightsView(pickerIndex: self.$pickerIndex).environmentObject(diningVM)
//                } else {
//                    Rectangle()
//                        .foregroundColor(.white)
//                        .frame(width:100, height: 100)
//                        .onTapGesture(perform: {
//                            alert = true
//                        })
//                }
                
            }
        }
        .alert(isPresented: $alert, content: {
            Alert(title: Text("Error"))
        })
        .padding(.top)
        .alert(type: diningVM.alertType, show: presentingAlert)
        .onAppear(perform: {
            UITableView.appearance().separatorStyle = .none
        })
    }
}

@available(iOS 14, *)
struct DiningView_Previews: PreviewProvider {
    
    static var previews: some View {
        DiningView()
    }
}
