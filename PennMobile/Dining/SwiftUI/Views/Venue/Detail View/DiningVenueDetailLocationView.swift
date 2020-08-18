//
//  DiningVenueDetailLocationView.swift
//  PennMobile
//
//  Created by CHOI Jongmin on 23/6/2020.
//  Copyright © 2020 PennLabs. All rights reserved.
//

import SwiftUI
import MapKit

struct DiningVenueDetailLocationView: View {
    
    @State private var region = PennCoordinate.shared.getRegion(for: .membership, at: .close)
    
    
    init(for venue: DiningVenue) {
        self.venue = venue
    }
    
    let venue: DiningVenue
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Description")
                .font(.system(size: 21, weight: .medium))
                .padding(.bottom)
            
            Text(description)
                .font(.system(size: 17, weight: .light)).italic()
            
        }
    }
}


let description = """
“1920 Commons, the largest café on campus, is located on Locust Walk, right across the 38th Street Bridge. Serving lunch, lite lunch, and dinner during the week and brunch and dinner on weekends. Enjoy a bountiful, seasonal salad bar; made-to-order deli; fresh, hot pizzas; comfort cuisine; savory soups; chicken, veggie burgers and beef burgers grilled to perfection; an ever-changing action station; or delectable desserts. It’s all here!”
"""

struct DiningVenueDetailLocationView_Previews: PreviewProvider {
    static var previews: some View {
        let path = Bundle.main.path(forResource: "sample-dining-venue", ofType: "json")
        let data = try! Data(contentsOf: URL(fileURLWithPath: path!), options: .mappedIfSafe)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let diningVenues = try! decoder.decode(DiningAPIResponse.self, from: data)
        return DiningVenueDetailLocationView(for: diningVenues.document.venues[0])
    }
}
