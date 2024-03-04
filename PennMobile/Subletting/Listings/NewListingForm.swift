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
    @EnvironmentObject var navigationManager: NavigationManager
    @EnvironmentObject var sublettingViewModel: SublettingViewModel
    @EnvironmentObject var popupManager: PopupManager
    @State var subletData = SubletData()
    @State var negotiable: Bool?
    @State var price: Int?
    @State var startDate: Date?
    @State var endDate: Date?
    @State var selectedAmenities = OrderedSet<String>()
    @State var images: [UIImage] = []
    @State var progress: Double?
    
    init() {
        self.subletData = SubletData()
        self.selectedAmenities = OrderedSet<String>()
        self.images = []
    }
    
//    init(sublet: Sublet) {
//        self.subletData = sublet.data
//        self.negotiable = sublet.negotiable
//        self.price = sublet.price
//        self.startDate = sublet.startDate.date
//        self.endDate = sublet.endDate.date
//        self.selectedAmenities = OrderedSet(sublet.amenities)
//        self.images = [] //sublet.images.forEach(body: (SubletImage) throws -> Void##(SubletImage) throws -> Void)
//    }
    
    var body: some View {
        ScrollView {
            LabsForm { formState in
                TextLineField($subletData.title, title: "Listing Name")
                
                ImagePicker($images, maxSelectionCount: 6)
                
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
                        if images.count == 0 {
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
                                var sublet = try await SublettingAPI.instance.createSublet(subletData: data)
                                sublettingViewModel.addListing(sublet: sublet)
                                do {
                                    popupManager.disableBackground = true
                                    sublet.images = try await SublettingAPI.instance.uploadSubletImages(images: images, id: sublet.subletID) { progress in
                                        self.progress = progress
                                    }
                                    sublet.lastUpdated = Date()
                                    sublettingViewModel.updateSublet(sublet: sublet)
                                } catch let error {
                                    print("Error uploading sublet images: \(error)")
                                }
                                print("Created sublet with id \(sublet.subletID)!")
                                self.progress = nil
                                popupManager.disableBackground = false
                                
                                popupManager.set(
                                    title: "Listing Posted!",
                                    message: "Your listing is now on the marketplace. You'll be notified when candidates are interested in subletting!",
                                    button1: "See My Listings",
                                    action1: {
                                        navigationManager.path.removeLast()
                                    }
                                )
                                popupManager.show()
                            } catch let error {
                                print("Couldn't create sublet: \(error)")
                                popupManager.set(
                                    image: Image(systemName: "exclamationmark.2"),
                                    title: "Uh oh!",
                                    message: "Failed to create the sublet.",
                                    button1: "Close"
                                )
                                popupManager.show()
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
        .overlay {
            if let progress = progress {
                UploadingOverlay(progress: progress, title: "Uploading...", message: "Your listing is being uploaded to the marketplace. Please wait a moment.")
            }
        }
    }
}

struct UploadingOverlay: View {
    let progress: Double
    let title: String
    let message: String
    
    var body: some View {
        ZStack {
            Color.black
                .opacity(0.2)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 18) {
                MeterView(current: progress, maximum: 1.0, style: Color.blue, lineWidth: 5)
                    .frame(width: 100, height: 100)
                Text(title)
                    .font(.headline)
                Text(message)
                    .font(.subheadline)
                    .multilineTextAlignment(.leading)
            }
            .frame(maxWidth: 280)
            .padding(.horizontal, 24)
            .padding(.vertical, 32)
            .background(Color("uiCardBackground"))
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.15), radius: 20, x: 0, y: 3)
        }
        .edgesIgnoringSafeArea(.all)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    }
}

#Preview {
    NewListingForm()
}
