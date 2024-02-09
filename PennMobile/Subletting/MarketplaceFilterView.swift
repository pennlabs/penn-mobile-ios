//
//  MarketplaceFilterView.swift
//  PennMobile
//
//  Created by Jordan H on 2/9/24.
//  Copyright © 2024 PennLabs. All rights reserved.
//

import SwiftUI
import PennForms

struct MarketplaceFilterView: View {
    @Environment(\.dismiss) var dismiss
    @State private var minPrice: Int?
    @State private var maxPrice: Int?
    @State private var location: String?
    @State private var startDate: Date?
    @State private var endDate: Date?
    @State private var beds: Int?
    @State private var baths: Int?
    @State private var selectedAmenities: [String] = []
    let amenities = [
        "Private bathroom", "In-unit laundry", "Gym", "Wifi",
        "Walk-in closet", "Furnished", "Utilities included", "Swimming pool",
        "Resident lounge", "Parking", "Patio", "Kitchen",
        "Dog-friendly", "Cat-friendly"
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LabsForm { formState in
                    PairFields {
                        NumericField($minPrice, format: .currency(code: "USD").presentation(.narrow), title: "Min Price/month")
                        NumericField($maxPrice, format: .currency(code: "USD").presentation(.narrow), title: "Max Price/month")
                    }
                    
                    TextLineField($location, placeholder: "Search", title: "Desired location")

                    DateRangeField(lowerDate: $startDate, upperDate: $endDate, title: "Start & End Date")
                    
                    PairFields {
                        NumericField($beds, title: "# Bed")
                        NumericField($baths, title: "# Bath")
                    }
                    
                    NumericField($baths, title: "# Bath")
                    
                    //TagSelector()
                    
                    ComponentWrapper {
                        HStack {
                            Button("Reset") {
                                // Reset action
                            }
                            .frame(maxWidth: .infinity)
                            
                            Button("Save") {
                                // Save action
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }
                }
            }
            .navigationBarTitle(Text("Filter by"), displayMode: .inline)
            .navigationBarItems(leading: Button(action: {
                dismiss()
            }) {
                Image(systemName: "xmark")
                    .foregroundColor(.black)
            }, trailing: Button(action: {
                dismiss()
            }) {
                Text("Save")
            })
        }
    }
}

#Preview {
    MarketplaceFilterView()
}
