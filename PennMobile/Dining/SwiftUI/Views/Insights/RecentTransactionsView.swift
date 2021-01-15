//
//  RecentTransactionsView.swift
//  PennMobile
//
//  Created by Dominic Holmes on 2/21/20.
//  Copyright © 2020 PennLabs. All rights reserved.
//

import Foundation
#if canImport(SwiftUI)
import SwiftUI
#endif

@available(iOS 14, *)
struct RecentTransactionsView: View {
    
    init(config: DiningInsightsAPIResponse.CardData.RecentTransactionsCardData) {
//        self.config = config
        data = config.data
    }
    
//    let config: DiningInsightsAPIResponse.CardData.RecentTransactionsCardData
    var data: [DiningTransaction]
    
    var body: some View {
        VStack(alignment: .leading) {
            
            CardHeaderView(color: .green, icon: .dollars, title: "Transactions", subtitle: "Your recent dining dollar transactions.")
            
            Divider()
                .padding(.top)
            
            VStack {
                ForEach(self.data, id: \.self) { trans in
                    VStack {
                        RecentTransactionsViewRow(transaction: trans)
                        Divider()
                    }
                }
            }
        }.padding()
    }
    
    struct RecentTransactionsViewRow: View {
        
        var transaction: DiningTransaction
        
        var body: some View {
            HStack {
                Image(systemName: "circle.fill")
                    .resizable()
                    .frame(width: 10, height: 10)
                    .foregroundColor(.orange)
                VStack(alignment: .leading) {
                    Text(transaction.location)
                    Text(transaction.formattedDate)
                        .font(.caption).foregroundColor(.gray)
                }
                Spacer()
                VStack(alignment: .trailing) {
                    Text(transaction.formattedAmount)
                        .fontWeight(.medium)
                        .foregroundColor(transaction.amount > 0 ? .green : .red)
                    Text(transaction.formattedBalance)
                        .font(.caption).foregroundColor(.gray)
                }
            }
        }
    }
}
