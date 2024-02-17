//
//  NewSublet.swift
//  PennMobile
//
//  Created by Anthony Li on 2/4/24.
//  Copyright © 2024 PennLabs. All rights reserved.
//

import SwiftUI
import PennForms
import PennMobileShared
import OSLog

private let logger = Logger(category: "NewListingForm")

struct NewListingForm: View {
    @State var subletData = SubletData()
    @State var negotiable: Bool?
    @State var price: Int?
    @State var startDate: Date?
    @State var endDate: Date?
    
    var body: some View {
        ScrollView {
            LabsForm { formState in
                TextLineField($subletData.title, title: "Listing Name")
                
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
                
                TextAreaField($subletData.description, characterCount: 300, title: "Description (optional)")
                
                ComponentWrapper {
                    Button(action: {
                        guard let negotiable, let price, let startDate, let endDate else {
                            return
                        }
                        
                        var data = subletData
                        data.price = price
                        data.negotiable = negotiable
                        data.startDate = Day(date: startDate)
                        data.endDate = Day(date: endDate)
                        data.expiresAt = Calendar.current.date(byAdding: .day, value: 3, to: Date())! // TODO: MAKE THIS AN EDITABLE FIELD
                        
                        Task {
                            if let token = await OAuth2NetworkManager.instance.getAccessTokenAsync() {
                                do {
                                    let sublet = try await SublettingAPI.instance.createSublet(subletData: data, accessToken: token.value)
                                    logger.info("Created sublet with id \(sublet.id), yay!")
                                } catch let e {
                                    logger.error("Couldn't create sublet: \(e)")
                                }
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
        .navigationTitle(Text("New Listing"))
    }
}

#Preview {
    NewListingForm()
}
