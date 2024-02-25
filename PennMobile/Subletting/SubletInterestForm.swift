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
    @EnvironmentObject var navigationManager: NavigationManager
    @EnvironmentObject var popupManager: PopupManager
    @Environment(\.dismiss) var dismiss
    @State var offerData = SubletOfferData()
    @State var phoneNumberInt: Int?
    var sublet: Sublet
    
    var body: some View {
        ScrollView {
            LabsForm { formState in
                // TODO: Fix this field formatting
                NumericField($phoneNumberInt, format: .phoneNumber, title: "Phone Number")
                
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
                            if let token = await OAuth2NetworkManager.instance.getAccessTokenAsync() {
                                do {
                                    let offer = try await SublettingAPI.instance.makeOffer(offerData: offerData, id: sublet.id, accessToken: token.value)
                                    print("Made offer with id \(offer.id) for sublet \(sublet.id)")
                                    
                                    popupManager.set(
                                        title: "Your Message Has Been Sent!",
                                        message: "The renter will reach out to you if interested.",
                                        button1: "See Applied",
                                        action1: {
                                            // TODO: Make this actually navigate to Applied
                                            popupManager.isShown = false
                                            dismiss()
                                        },
                                        button2: "Keep Browsing",
                                        action2: {
                                            popupManager.isShown = false
                                            dismiss()
                                        }
                                    )
                                    popupManager.isShown = true
                                } catch let error {
                                    if let sublettingError = error as? SublettingError, sublettingError == .alreadyExists {
                                        popupManager.set(
                                            image: Image(systemName: "exclamationmark.2"),
                                            title: "Already sent offer!",
                                            message: "You have already made an offer for this sublet.",
                                            button1: "Close",
                                            action1: {
                                                popupManager.isShown = false
                                                dismiss()
                                            }
                                        )
                                        popupManager.isShown = true
                                    } else {
                                        print("Couldn't make offer: \(error)")
                                    }
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
