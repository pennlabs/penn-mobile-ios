//
//  NewListingForm.swift
//  PennMobile
//
//  Created by Anthony Li on 2/4/24.
//  Copyright © 2024 PennLabs. All rights reserved.
//

import SwiftUI
import PennForms
import PennMobileShared
import OrderedCollections

struct NewListingForm: View {
    @EnvironmentObject var sublettingViewModel: SublettingViewModel
    @EnvironmentObject var popupManager: PopupManager
    @Environment(\.dismiss) var dismiss
    @State var subletData = SubletData()
    @State var negotiable: Bool?
    @State var price: Int?
    @State var startDate: Date?
    @State var endDate: Date?
    @State var selectedAmenities = OrderedSet<String>()
    @State var images: [Image] = []
    @State var imageData: [Data] = []
    
    var body: some View {
        ScrollView {
            LabsForm { formState in
                TextLineField($subletData.title, title: "Listing Name")
                
                ImagePicker($images, imageData: $imageData, maxSelectionCount: 6)
                
                PairFields {
                    NumericField($price, format: .currency(code: "USD").presentation(.narrow), title: "Price/month")
                    OptionField($negotiable, options: [false, true], toString: { option in
                        option ? "Yes" : "No"
                    }, title: "Negotiable?")
                }
                
                TextLineField($subletData.address, placeholder: "Street address", title: "Location")
                
                DateRangeField(lowerDate: $startDate, upperDate: $endDate, title: "Start & End Date")
                
                PairFields {
                    NumericField($subletData.beds, title: "# Bed")
                    NumericField($subletData.baths, title: "# Bath")
                }
                
                TextLineField($subletData.externalLink, title: "External Link")
                
                DateField(date: $subletData.expiresAt, title: "Listing Expiry Date")
                
                ComponentWrapper {
                    Text("Amenities")
                        .bold()
                }
                
                TagSelector(selection: $selectedAmenities, tags: $sublettingViewModel.amenities)
                
                TextAreaField($subletData.description, characterCount: 300, title: "Description (optional)")
                
                ComponentWrapper {
                    Button(action: {
                        guard let negotiable, let price, let startDate, let endDate else {
                            return
                        }
                        if imageData.count == 0 {
                            return
                        }
                        
                        var data = subletData
                        data.price = price
                        data.negotiable = negotiable
                        data.startDate = Day(date: startDate)
                        data.endDate = Day(date: endDate)
                        data.amenities = Array(selectedAmenities)
                        
                        Task {
                            do {
                                let sublet = try await SublettingAPI.instance.createSublet(subletData: data)
                                do {
                                    try await SublettingAPI.instance.uploadSubletImages(images: imageData, id: sublet.subletID)
                                } catch let error {
                                    print("Error uploading sublet images: \(error)")
                                }
                                print("Created sublet with id \(sublet.subletID)!")
                                
                                popupManager.set(
                                    title: "Listing Posted!",
                                    message: "Your listing is now on the marketplace. You'll be notified when candidates are interested in subletting!",
                                    button1: "See My Listings",
                                    action1: {
                                        dismiss()
                                    }
                                )
                                popupManager.show()
                            } catch let error {
                                popupManager.set(
                                    image: Image(systemName: "exclamationmark.2"),
                                    title: "Uh oh!",
                                    message: "Failed to create the sublet.",
                                    button1: "Close"
                                )
                                popupManager.show()
                                print("Couldn't create sublet: \(error)")
                            }
                        }
                    }) {
                        Text("Post")
                            .font(.title3)
                            .bold()
                            .foregroundColor(Color.white)
                            .padding(.vertical, 10)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .background(
                                Capsule()
                                    .fill(formState.isValid ? Color.baseLabsBlue : .gray)
                            )
                    }
                    .padding(.top, 30)
                    .disabled(!formState.isValid)
                }
            }
        }
        .navigationTitle("New Listing")
    }
}

#Preview {
    NewListingForm()
}
