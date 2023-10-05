//
//  MoreView.swift
//  PennMobile
//
//  Created by Anthony Li on 10/5/23.
//  Copyright © 2023 PennLabs. All rights reserved.
//

import SwiftUI

struct MoreView: View {
    var features: [AppFeature]
    
    @State var isShowingPreferences = false
    
    var body: some View {
        ScrollView {
            VStack {
                HStack {
                    VStack(alignment: .leading) {
                        Text("Features")
                            .fontWeight(.medium)
                        Text("To pin these to the tab bar, tap Edit.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Button("Edit") {
                        isShowingPreferences = true
                    }
                    .buttonStyle(.bordered)
                    .buttonBorderShape(.capsule)
                }
                .padding(.horizontal)
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 80, maximum: 80), alignment: .top)], spacing: 16) {
                    ForEach(features) { feature in
                        NavigationLink {
                            feature.content
                        } label: {
                            VStack {
                                feature.image
                                    .scaledToFit()
                                    .frame(width: 32, height: 32)
                                    .padding(12)
                                    .background(feature.color)
                                    .clipShape(.rect(cornerRadius: 8))
                                Text(feature.longName).font(.caption)
                            }
                        }.tint(.primary)
                    }
                }
                .padding(.top, 16)
            }
        }
        .navigationTitle(Text("More"))
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $isShowingPreferences, content: {
            PreferencesView()
                .presentationDetents([.fraction(0.7)])
                .presentationDragIndicator(.visible)
        })
    }
}
