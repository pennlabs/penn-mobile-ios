//
//  HomeSublettingBanner.swift
//  PennMobile
//
//  Created by Anthony Li on 4/14/24.
//  Copyright © 2024 PennLabs. All rights reserved.
//

import SwiftUI

struct HomeSublettingBanner: View {
    var onStart: () -> Void
    var onDismiss: () -> Void
    
    static let gradient = LinearGradient(colors: [Color("Subletting Gradient 1"), Color("Subletting Gradient 2")], startPoint: .topLeading, endPoint: .bottomTrailing)
    
    var body: some View {
        HomeCardView {
            VStack {
                Text("Penn Mobile Sublet is here!")
                    .fontWeight(.bold)
                    .font(.title2)
                Text("Browse and list places to live, right from Penn Mobile. Find it in the **More** tab.")
                Button {
                    onStart()
                } label: {
                    HStack {
                        Text("Get started")
                        BetaBadge()
                        Image(systemName: "arrow.forward")
                    }
                    .font(.title3)
                    .foregroundStyle(Color("Subletting Gradient 2"))
                }
                .buttonStyle(BorderedProminentButtonStyle())
                .buttonBorderShape(.capsule)
                .tint(.white)
                .fontWeight(.medium)
                .frame(maxWidth: .infinity)
                .padding(.top, 150)
                .background {
                    HStack {
                        Image("My Listings")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80)
                            .clipShape(.rect(cornerRadius: 12))
                            .shadow(radius: 4)
                            .rotationEffect(.degrees(-9))
                        Image("Listing")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80)
                            .clipShape(.rect(cornerRadius: 12))
                            .shadow(radius: 4)
                            .rotationEffect(.degrees(9))
                    }
                    .padding(.top)
                    .frame(maxWidth: .infinity)
                    .mask {
                        Rectangle()
                            .fill(LinearGradient(colors: [.white, .clear], startPoint: .center, endPoint: .init(x: 0.5, y: 0.85)))
                    }
                }
                /* Button("Not right now") {
                    onDismiss()
                }
                .tint(.white)
                .padding(.top, 4) */
            }
            .padding()
            .multilineTextAlignment(.center)
            .background(Self.gradient)
            .environment(\.colorScheme, .dark)
        }
    }
}

#Preview {
    HomeSublettingBanner {} onDismiss: {}
        .padding()
}
