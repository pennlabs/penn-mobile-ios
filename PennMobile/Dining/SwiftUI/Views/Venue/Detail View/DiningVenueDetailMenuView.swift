//
//  DiningVenueDetailMenuView.swift
//  PennMobile
//
//  Created by CHOI Jongmin on 23/6/2020.
//  Copyright © 2020 PennLabs. All rights reserved.
//

import SwiftUI

@available(iOS 14.0, *)
struct DiningVenueDetailMenuView: View {
    
    var menus: [DiningMenu] = []
    
    init() {
        let path = Bundle.main.path(forResource: "mock_menu", ofType: "json")
        let data = try! Data(contentsOf: URL(fileURLWithPath: path!), options: .mappedIfSafe)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let menuAPI = try! decoder.decode(DiningMenuAPIResponse.self, from: data)
        self.menus = menuAPI.document.menuDocument.menus
    }
    
    var body: some View {
        ForEach(menus, id: \.self) { menu in
            DiningMenuRow(for: menu)
        }
    }
}

@available(iOS 14.0, *)
struct DiningVenueDetailMenuView_Previews: PreviewProvider {
    let diningVenues: DiningMenuAPIResponse = Bundle.main.decode("mock_menu.json")
    
    static var previews: some View {
        return NavigationView {
            ScrollView {
                VStack {
                    DiningVenueDetailMenuView()
                    Spacer()
                }
            }.navigationTitle("Dining")
            .padding()
        }
    }
}
