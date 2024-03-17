//
//  SubletInterestForm.swift
//  PennMobile
//
//  Created by Jordan H on 2/25/24.
//  Copyright © 2024 PennLabs. All rights reserved.
//

import SwiftUI
import PennForms
import PennMobileShared

struct SubletInterestForm: View {
    @EnvironmentObject var sublettingViewModel: SublettingViewModel
    @EnvironmentObject var navigationManager: NavigationManager
    @EnvironmentObject var popupManager: PopupManager
    @State var offerData = SubletOfferData()
    @State var phoneNumberInt: Int?
    let sublet: Sublet
    
    var body: some View {
        ScrollView {
            LabsForm { formState in
                // TODO: Fix this field formatting
                NumericField($phoneNumberInt, format: .phoneNumber, title: "Phone Number")
                    .validator(.required)
                
                TextAreaField($offerData.message, characterCount: 300, title: "Message (optional)")
                
                ComponentWrapper {
                    Button(action: {
                        guard let phoneNumberInt, let email = Account.getAccount()?.email else {
                            return
                        }
                        if String(phoneNumberInt).count != 10 {
                            return
                        }
                        
                        offerData.phoneNumber = "+1\(phoneNumberInt)"
                        offerData.email = email
                        
                        Task {
                            do {
                                let offer = try await SublettingAPI.instance.makeOffer(offerData: offerData, id: sublet.subletID)
                                var updatedSublet = sublet
                                updatedSublet.offers = (updatedSublet.offers ?? []) + [offer]
                                updatedSublet.lastUpdated = Date()
                                sublettingViewModel.addApplied(sublet: updatedSublet)
                                print("Made offer with id \(offer.id) for sublet \(sublet.subletID)")
                                
                                popupManager.set(
                                    title: "Your Message Has Been Sent!",
                                    message: "The renter will reach out to you if interested.",
                                    button1: "See Applied",
                                    action1: {
                                        navigationManager.path.removeLast(navigationManager.path.contains(SublettingPage.myActivity(.saved)) ? 3 : 2)
                                        navigationManager.path.append(SublettingPage.myActivity(.applied))
                                    },
                                    button2: "Keep Browsing",
                                    action2: {
                                        navigationManager.path.removeLast()
                                    }
                                )
                                popupManager.show()
                            } catch let error {
                                if let sublettingError = error as? NetworkingError, sublettingError == .alreadyExists {
                                    popupManager.set(
                                        image: Image(systemName: "exclamationmark.2"),
                                        title: "Already sent offer!",
                                        message: "You have already made an offer for this sublet.",
                                        button1: "Close",
                                        action1: {
                                            navigationManager.path.removeLast()
                                        }
                                    )
                                    popupManager.show()
                                } else {
                                    print("Couldn't make offer: \(error)")
                                }
                            }
                        }
                    }) {
                        Text("Send")
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
        .navigationTitle("Send Interest")
    }
}

#Preview {
    SubletInterestForm(sublet: Sublet.mock)
}
