//
//  RefactorDiningBalanceView.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 1/12/25.
//  Copyright © 2025 PennLabs. All rights reserved.
//

import SwiftUI
import PennMobileShared

struct RefactorDiningBalanceView: View {
    @State var showingAnalytics: Bool = false
    
    var body: some View {
        Grid(horizontalSpacing: 12, verticalSpacing: 12) {
            GridRow {
                BalanceCard(value: 120.20, type: .dollars, subtitle: "Dining Dollars", systemImage: "dollarsign.circle.fill")
                BalanceCard(value: 69, type: .swipes, subtitle: "Swipes", systemImage: "creditcard.fill")
            }
            GridRow {
                BalanceCard(value: 10, type: .swipes, subtitle: "Guest Swipes", systemImage: "person.2.fill")
                AnalyticsCard($showingAnalytics)
            }
        }
        .blur(radius: Account.isLoggedIn ? 0 : 8)
        .allowsHitTesting(Account.isLoggedIn)
        .sheet(isPresented: $showingAnalytics, onDismiss: { showingAnalytics = false}) {
            Text("Analytics!")
        }
        .overlay {
            // TODO: Check Campus Express instead of General Login
            if !Account.isLoggedIn {
                VStack {
                    Text("Dining Analytics")
                        .font(.title)
                        .bold()
                        .foregroundStyle(.blue)
                    Text("Log in to see your dining balances and usage graphs.")
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.blue)
                    
                    Text("Log in with Campus Express")
                        .bold()
                        .foregroundStyle(.white)
                        .padding(.horizontal)
                        .padding(.vertical, 6)
                        .background {
                            Capsule()
                                .foregroundStyle(.blue)
                        }
                        
                        .padding()
                        .onTapGesture {
                            print("Login Handler")
                        }
                }
                .shadow(radius: 1)
                .background {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color.clear)
                        .shadow(color: Color.black.opacity(0.2), radius: 4, x: 2, y: 2)
                }
                
            }
        }
        
        
        
    }
}

struct AnalyticsCard: View {
    @Binding var showing: Bool
    
    init(_ showing: Binding<Bool>) {
        self._showing = showing
    }
    var body: some View {
        CardView {
            HStack {
                Text("Analytics")
                    .font(.title2)
                    .bold()
                Spacer()
                Image(systemName: "chevron.right")
                    .padding(.trailing, 16)
            }
            .foregroundStyle(.blue)
            .padding(.vertical, 12)
            .padding(.horizontal, 4)
        }
        .onTapGesture {
            showing = true
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
        CardView {
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
            }
            .foregroundStyle(.blue)
            .padding(.vertical, 12)
            .padding(.horizontal, 4)
        }
    }
}


//potentially refactor to a more public class, cuz i can imagine this being used everywhere
enum BalanceType {
    case dollars, swipes
}

#Preview {
    RefactorDiningBalanceView()
}
