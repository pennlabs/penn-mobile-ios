//
//  ProfileView.swift
//  PennMobile
//
//  Created by Andrew Antenberg on 9/26/21.
//  Copyright © 2021 PennLabs. All rights reserved.
//

import SwiftUI
import PennMobileShared

struct ProfileView: View {
    let account: Account
    let refresh: () async -> Void

    var body: some View {
        List {
            Section {
                ProfilePlaceholderView(account: account)
                    .frame(maxWidth: .infinity)
                    .listRowBackground(Color.clear)

                LabeledContent("Username", value: account.username)
                if let email = account.email {
                    LabeledContent("Email", value: email)
                }
            } header: {
                Text("Profile")
            } footer: {
                Text("If your information is incorrect, please send an email to contact@pennlabs.org detailing your issue.")
            }

            Section {
                let schools = account.student.school.map(\.name)
                let majors = account.student.major.map(\.name)

                LabeledContent("Graduation Year", value: account.student.graduationYear.map(String.init) ?? "")
                LabeledContent(schools.count > 1 ? "Schools" : "School", value: schools.joined(separator: ", "))
                LabeledContent(majors.count > 1 ? "Majors" : "Major", value: majors.joined(separator: ", "))
            } header: {
                Text("Education")
            }
        }
        .task {
            await refresh()
        }
        .refreshable {
            await refresh()
        }
    }
}
