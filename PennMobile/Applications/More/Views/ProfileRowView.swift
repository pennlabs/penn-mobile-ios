//
//  ProfileRowView.swift
//  PennMobile
//
//  Created by Anthony Li on 10/8/23.
//  Copyright © 2023 PennLabs. All rights reserved.
//

import SwiftUI
import PennMobileShared

extension Account {
    var nameComponents: PersonNameComponents {
        PersonNameComponents(givenName: firstName, familyName: lastName)
    }
}

struct ProfilePlaceholderView: View {
    var account: Account?

    let nameFormatter: PersonNameComponentsFormatter = {
        let formatter = PersonNameComponentsFormatter()
        formatter.style = .abbreviated
        return formatter
    }()

    var body: some View {
        if let account {
            Text(nameFormatter.string(from: account.nameComponents))
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .multilineTextAlignment(.center)
                .foregroundStyle(.white)
                .frame(width: 60, height: 60)
                .background(Color("baseLabsBlue"))
                .clipShape(.circle)
        } else {
            Image(systemName: "person.crop.circle.fill")
                .resizable()
                .frame(width: 60, height: 60)
        }
    }
}

struct ProfileRowView: View {
    var account: Account?

    let nameFormatter = PersonNameComponentsFormatter()

    var body: some View {
        HStack(spacing: 12) {
            ProfilePlaceholderView(account: account)
                .alignmentGuide(.listRowSeparatorLeading) { dimension in
                    dimension[.leading]
                }
            VStack(alignment: .leading) {
                if let account {
                    Text(nameFormatter.string(from: account.nameComponents))
                        .font(.title2)
                        .fontWeight(.bold)
                    Text("Profile")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                } else {
                    Text("Loading Account...")
                        .font(.title2)
                        .fontWeight(.bold)
                }
            }
        }
    }
}

#Preview {
    List {
        ProfileRowView(account: nil)
    }
}
