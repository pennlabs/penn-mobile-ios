//
//  DiningViewHeader.swift
//  PennMobile
//
//  Created by CHOI Jongmin on 4/6/2020.
//  Copyright © 2020 PennLabs. All rights reserved.
//

#if canImport(SwiftUI)
import SwiftUI
#endif

@available(iOS 14, *)
struct DiningViewHeader: View {
    
    @EnvironmentObject var diningVM: DiningViewModelSwiftUI
    
    var body: some View {
        HStack {
            DiningViewHeaderDate()
            
            Spacer()
            
            DiningViewHeaderBalance()
                .environmentObject(diningVM)
        }
    }
}

@available(iOS 14, *)
struct DiningViewHeaderDate: View {
    var dateString: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, MMMM d"
        return dateFormatter.string(from: Date()).uppercased()
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(dateString)
                .font(.system(size: 11, weight: .bold, design: .default))
                .foregroundColor(.gray)
            
            Text("Dining")
                .font(.system(size: 28, weight: .bold, design: .default))
        }
    }
}

@available(iOS 14, *)
struct DiningViewHeaderBalance: View {
    @EnvironmentObject var diningVM: DiningViewModelSwiftUI
    
    var body: some View {
        VStack(alignment: .trailing) {
            Label("\(diningVM.swipes)", systemImage: "creditcard.fill")
                .labelStyle(BalanceLabelStyle())
            
            Label("\(String(format: "%.2f", diningVM.diningDollars))", systemImage: "dollarsign.circle.fill")
                .labelStyle(BalanceLabelStyle())
        }
    }
}

struct BalanceLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.title
                .font(.system(size: 17, weight: .bold, design: .rounded))
            configuration.icon
                .frame(width:20, height: 20)
        }
    }
}

@available(iOS 14, *)
struct DiningViewHeader_Previews: PreviewProvider {
    static var previews: some View {
        DiningViewHeaderBalance()
    }
}
