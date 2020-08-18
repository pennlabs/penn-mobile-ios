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

@available(iOS 13, *)
struct DiningViewHeader: View {
    
    @ObservedObject var diningVM = DiningViewModelSwiftUI.instance
    
    var dateString: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, MMMM d"
        return dateFormatter.string(from: Date()).uppercased()
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(dateString)
                    .font(.system(size: 11, weight: .bold, design: .default))
                    .foregroundColor(.gray)
                
                Text("Dining")
                    .font(.system(size: 28, weight: .bold, design: .default))
            }
            
            Spacer()
            
            VStack(alignment: .trailing) {
                HStack {
                    Text("\(diningVM.diningInsights?.swipes ?? 0)")
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                        
                    Image(systemName: "creditcard.fill")
                }
                
                HStack {
                    Text("\(String(format: "%.2f", diningVM.diningInsights?.diningDollars ?? 0))")
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                        
                    Image(systemName: "dollarsign.circle.fill")
                }
            }
        }
    }
}

@available(iOS 13, *)
struct DiningViewHeader_Previews: PreviewProvider {
    static var previews: some View {
        DiningViewHeader()
    }
}
