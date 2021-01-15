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
    
    @State var isModal: Bool = false
    
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
        VStack {
            ForEach(menus, id: \.self) { menu in
                Section(header: Text(menu.mealType)) {
                    ForEach(menu.stations, id: \.self) { station in
                        Button("\(station.stationDescription)") {
                            self.isModal = true
                        }.sheet(isPresented: $isModal, content: {
                            StationItemView(for: station)
                        })
                    }
                }
            }
        }
//        Text("dasf")
    }
}


struct StationItemView: View {
    
    init(for station: DiningStation) {
        self.station = station
    }
    
    let station: DiningStation
    
    var body: some View {
        List {
            ForEach(station.diningStationItems, id: \.self) { item in
                Section(header: Text(item.title)) {
                    ForEach(item.tableAttribute.attributeDescriptions, id: \.self) { attribute in
                        Text("\(attribute.description)")
                    }
                }
            }
        }
    }
}

@available(iOS 14.0, *)
struct DiningVenueDetailMenuView_Previews: PreviewProvider {
    let diningVenues: DiningMenuAPIResponse = Bundle.main.decode("mock_menu.json")
    
    static var previews: some View {
        return NavigationView {
             DiningVenueDetailMenuView()
        }.navigationTitle("Dining")
    }
}
