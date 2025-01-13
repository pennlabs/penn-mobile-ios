//
//  RefactorDiningBalanceView.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 1/12/25.
//  Copyright © 2025 PennLabs. All rights reserved.
//

import SwiftUI

struct RefactorDiningBalanceView: View {
    var body: some View {
        
        Grid(horizontalSpacing: 12, verticalSpacing: 12) {
            GridRow {
                BalanceCard(value: 120.20, type: .dollars, subtitle: "Dining Dollars", systemImage: "dollarsign.circle.fill")
                BalanceCard(value: 69, type: .swipes, subtitle: "Swipes", systemImage: "creditcard.fill")
            }
            GridRow {
                BalanceCard(value: 10, type: .swipes, subtitle: "Guest Swipes", systemImage: "person.2.fill")
                
                
                NavigationLink {
                    Text("Analytics")
                        .navigationTitle("Analytics!")
                } label: {
                    Group {
                        HStack {
                            Text("Analytics")
                                .font(.title2)
                                .bold()
                            Spacer()
                            Image(systemName: "chevron.right")
                        }
                        
                        .foregroundStyle(.blue)
                        .padding()
                        
                        
                        
                    }
                    .frame(minHeight: 75)
                    .background(.background)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .shadow(radius: 4)
                }
            }
        }
    }
}

struct BalanceCard: View {
    
    let value: String
    let type: BalanceType
    let subtitle: String
    let systemImage: String
    
    init(value: Double, type: BalanceType, subtitle: String, systemImage: String) {
        switch type {
        case .dollars:
            self.value = String(format: "$%.2f", value)
        default:
            self.value = String(format: "%.0f", value)
        }
        self.type = type
        self.subtitle = subtitle
        self.systemImage = systemImage
    }
    
    var body: some View {
        Group {
            HStack {
                Image(systemName: systemImage)
                    .font(.title2)
                    .padding()
                Spacer()
                VStack(alignment: .trailing) {
                    Text("\(value)")
                        .font(.title2)
                        .bold()
                    Text(subtitle)
                        .font(.caption2)
                        .foregroundStyle(.gray)
                }
                .multilineTextAlignment(.trailing)
                .padding(.trailing, 8)
            }.foregroundStyle(.blue)
        }
        .frame(minHeight: 75)
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .shadow(radius: 4)
    }
}


//potentially refactor to a more public class, cuz i can imagine this being used everywhere
enum BalanceType {
    case dollars, swipes
}

#Preview {
    RefactorDiningBalanceView()
}
