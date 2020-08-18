//
//  DiningVenueDetailMenuView.swift
//  PennMobile
//
//  Created by CHOI Jongmin on 23/6/2020.
//  Copyright © 2020 PennLabs. All rights reserved.
//

import SwiftUI

struct DiningVenueDetailMenuView: View {
//
//    init(for venue: DiningVenue) {
//        self.venue = venue
//    }
    
    var test: String
    
    init() {
        let path = Bundle.main.path(forResource: "mock_menu", ofType: "json")
        let data = try! Data(contentsOf: URL(fileURLWithPath: path!), options: .mappedIfSafe)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let menuAPI = try! decoder.decode(DiningMenuAPIResponse.self, from: data)
        self.test = menuAPI.document.location
    }
    
    var body: some View {
        Text(test)
//        Text("dafs")
    }
}

struct DiningVenueDetailMenuView_Previews: PreviewProvider {
    static var previews: some View {
        
        return DiningVenueDetailMenuView()
    }
}
