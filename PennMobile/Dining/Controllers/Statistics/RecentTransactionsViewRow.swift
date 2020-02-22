//
//  RecentTransactionsViewRow.swift
//  PennMobile
//
//  Created by Dominic Holmes on 2/21/20.
//  Copyright © 2020 PennLabs. All rights reserved.
//

import Foundation
#if canImport(SwiftUI)
import SwiftUI
#endif

@available(iOS 13.0, *)
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
                Text(String(transaction.balance))
                    .font(.caption).foregroundColor(.gray)
            }
        }
    }
}

@available(iOS 13.0, *)
struct RecentTransactionsViewRow_Previews: PreviewProvider {
    static var previews: some View {
        RecentTransactionsViewRow(transaction: .init(location: "Van Pelt Cafe", date: Date(), balance: -12.45, amount: 145.66))
    }
}
