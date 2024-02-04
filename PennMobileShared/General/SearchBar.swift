//
//  SearchBar.swift
//  PennMobileShared
//
//  Created by Jordan H on 2/4/24.
//  Copyright © 2024 PennLabs. All rights reserved.
//

import SwiftUI

public struct SearchBar: View {
    @Binding public var searchText: String
    
    public init(searchText: Binding<String>) {
        self._searchText = searchText
    }

    public var body: some View {
        TextField("Search", text: $searchText)
            .placeholder(when: searchText.isEmpty) {
                Text("Search")
                    .foregroundColor(.secondary)
            }
            .padding(7)
            .padding(.horizontal, 25)
            .foregroundColor(.primary)
            .accentColor(.primary)
            .background(.quinary)
            .cornerRadius(30)
            .overlay(
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.primary)
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 8)
                    
                    if !searchText.isEmpty {
                        Button(action: {
                            self.searchText = ""
                        }) {
                            Image(systemName: "multiply.circle.fill")
                                .foregroundColor(.secondary)
                                .padding(.trailing, 8)
                        }
                    }
                }
            )
            .frame(maxWidth: .infinity)
    }
}
