//
//  SubletCandidatesView.swift
//  PennMobile
//
//  Created by Jordan H on 2/25/24.
//  Copyright © 2024 PennLabs. All rights reserved.
//

import SwiftUI

struct CandidateRow: View {
    let offer: SubletOffer
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "envelope")
                
                Menu {
                    Button(action: {
                        guard let url = URL(string: "mailto:\(offer.email)") else { return }
                        UIApplication.shared.open(url)
                    }) {
                        Label("Send Email", systemImage: "envelope")
                    }
                    
                    Button(action: {
                        UIPasteboard.general.string = offer.email
                    }) {
                        Label("Copy Email", systemImage: "doc.on.doc")
                    }
                } label: {
                    Text(offer.email)
                        .font(.headline)
                }
            }
            
            HStack {
                Image(systemName: "phone")
                Menu {
                    Button(action: {
                        guard let url = URL(string: "tel:\(offer.phoneNumber)") else { return }
                        UIApplication.shared.open(url)
                    }) {
                        Label("Call Number", systemImage: "phone")
                    }
                    
                    Button(action: {
                        guard let url = URL(string: "sms:\(offer.phoneNumber)") else { return }
                        UIApplication.shared.open(url)
                    }) {
                        Label("Send Message", systemImage: "message")
                    }
                    
                    Button(action: {
                        UIPasteboard.general.string = offer.phoneNumber
                    }) {
                        Label("Copy", systemImage: "doc.on.doc")
                    }
                } label: {
                    Text(offer.phoneNumber)
                        .font(.headline)
                }
            }
            .font(.subheadline)
            
            if offer.message != nil && !offer.message!.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                Text("\"\(offer.message!)\"")
            }
            
            Text("Submitted \(formatDate(offer.createdDate))")
                .font(.subheadline)
                .italic()
        }
        .padding(.horizontal)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d, yyyy"
        return formatter.string(from: date)
    }
}

struct SubletCandidatesView: View {
    let sublet: Sublet
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Candidates")
                .font(.title2)
                .bold()
                .lineLimit(1)
            
            Text("Contact your candidates to begin negotiating!")
                .font(.subheadline)
                .lineLimit(1)
            
            if sublet.offers == nil || sublet.offers!.count == 0 {
                Spacer()
                VStack {
                    Text("There do not appear to be any candidates yet!")
                        .foregroundStyle(.tertiary)
                        .font(.subheadline)
                }
            } else {
                VStack(alignment: .leading) {
                    ForEach(sublet.offers ?? []) { offer in
                        CandidateRow(offer: offer)
                        Divider()
                    }
                }
            }
            
            Spacer()
        }
        .padding()
    }
}

#Preview {
    SubletCandidatesView(sublet: Sublet.mock)
}
