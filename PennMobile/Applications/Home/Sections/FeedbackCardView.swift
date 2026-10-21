//
//  FeedbackCardView.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 10/21/26.
//  Copyright © 2026 PennLabs. All rights reserved.
//

import SwiftUI

struct FeedbackCardView: View {
    var body: some View {
        HomeCardView {
            Link(destination: URL(string: "https://pennlabs.org/feedback/ios")!) {
                Text("Share Your Feedback")
                    .fontWeight(.medium)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 12)
                    .padding(.horizontal)
            }
            .tint(.blue)
        }
    }
}
