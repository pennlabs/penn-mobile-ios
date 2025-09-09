//
//  ContactRowView.swift
//  PennMobile
//
//  Created by Jordan Hochman on 11/16/24.
//  Copyright © 2024 PennLabs. All rights reserved.
//

import SwiftUI

struct ContactRowView: View {
    let contact: Contact
    @State var isExpanded = false
    
    var body: some View {
        HStack {
            Button(action: {
                withAnimation {
                    isExpanded.toggle()
                }
            }) {
                HStack {
                    VStack(alignment: .leading) {
                        Text(contact.name)

                        if isExpanded {
                            Text(contact.phone)
                                .font(.subheadline)
                            
                            if let desc = contact.description {
                                Text(desc)
                                    .font(.subheadline)
                            }
                        }
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        call(number: contact.phoneFiltered)
                    }) {
                        HStack {
                            Image(systemName: "phone.fill")
                            Text("Call")
                                .fontWeight(.medium)
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.green)
                    .fixedSize(horizontal: true, vertical: true)
                    
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(.gray)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
    }
    
    private func call(number: String) {
        guard let url = URL(string: "tel://" + number) else {
            return
        }
        UIApplication.shared.open(url)
    }
}

#Preview {
    ContactRowView(contact: Contact.pennGeneral)
}
