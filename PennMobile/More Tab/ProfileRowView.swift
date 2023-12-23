//
//  ProfileRowView.swift
//  PennMobile
//
//  Created by Anthony Li on 10/8/23.
//  Copyright © 2023 PennLabs. All rights reserved.
//

import SwiftUI

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
        Group {
            if let account {
                Text(nameFormatter.string(from: account.nameComponents))
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.white)
                    .frame(width: 60, height: 60)
                    .background(Color.baseLabsBlue)
                    .clipShape(.circle)
            } else {
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .frame(width: 60, height: 60)
            }
        }
    }
}

struct ProfileRowView: View {
    var account: Account?
    
    let nameFormatter = PersonNameComponentsFormatter()
    
    var body: some View {
        HStack(spacing: 12) {
            ProfilePlaceholderView(account: account)
                .alignmentGuide(.listRowSeparatorLeading, computeValue: { dimension in
                    dimension[.leading]
                })
            VStack(alignment: .leading) {
                if let account {
                    Text(nameFormatter.string(from: account.nameComponents))
                        .font(.title2)
                        .fontWeight(.bold)
                    Text("Profile")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                } else {
                    Text("Log in with PennKey")
                        .font(.title2)
                        .fontWeight(.bold)
                    Text("Set up Dining Analytics and more")
                        .font(.subheadline)
                }
            }
        }
    }
}

#Preview {
    List {
        // I asked ChatGPT for this please don't judge
        ProfileRowView(account: Account(
            pennid: 123456789,
            firstName: "Darth",
            lastName: "Penguin",
            username: "WobblyFlippers",
            email: "IceColdEmpire@antarctica.net",
            student: Student(
                major: [
                    Major(id: 1, name: "Unicorn Studies", degreeType: "Bachelor of Magical Arts"),
                    Major(id: 2, name: "Rainbow Physics", degreeType: "Master of Colorful Science")
                ],
                school: [
                    School(id: 1, name: "Hogwarts School of Witchcraft and Wizardry"),
                    School(id: 2, name: "Starfleet Academy")
                ],
                graduationYear: 3099
            ),
            groups: ["Iceberg Climbers", "Mumble's Dance Crew"],
            emails: [
                Email(
                    id: 101,
                    value: "FlyingElephant@zooinspace.com",
                    primary: true,
                    verified: false
                ),
                Email(
                    id: 102,
                    value: "DancingGiraffe@jungleboogie.com",
                    primary: false,
                    verified: true
                )
            ]))
    }
}
