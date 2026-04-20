//
//  WellnessView.swift
//  PennMobile
//
//  Created by Kaitlyn Kwan on 4/9/26.
//  Copyright © 2026 PennLabs. All rights reserved.
//

import SwiftUI

// MARK: - Models

struct WellnessResource: Identifiable {
    let id = UUID()
    let name: String
    let callActions: [(label: String, number: String)]
    let websiteURL: String?
    let locationLabel: String?
    let emailAddress: String?
    let description: String
}

struct WellnessCategory: Identifiable {
    let id = UUID()
    let name: String
    let sfSymbol: String
    let resources: [WellnessResource]
}

// MARK: - Static Data

private let wellnessCategories: [WellnessCategory] = [
    WellnessCategory(
        name: "Mental Health & Wellness",
        sfSymbol: "brain",
        resources: [
            WellnessResource(
                name: "Counseling and Psychological Services (CAPS)",
                callActions: [("Call 215-746-9355 (24/7)", "2157469355")],
                websiteURL: "https://wellness.upenn.edu",
                locationLabel: "3624 Market St (Counseling) · 3535 Market St (Health)",
                emailAddress: nil,
                description: "Support for stress, anxiety, depression, relationship problems, identity issues, crisis care, therapy, and medications. You do not need to have a crisis to seek help — general emotional support and early interventions are encouraged."
            ),
            WellnessResource(
                name: "Crisis Support",
                callActions: [
                    ("Call 988 (24/7 national crisis lifeline)", "988"),
                    ("Call 215-573-3333 (24/7 on-campus emergency)", "2155733333"),
                    ("Call 911 (off-campus emergency)", "911"),
                    ("Call 215-898-4357 (worried about a friend)", "2158984357")
                ],
                websiteURL: nil,
                locationLabel: nil,
                emailAddress: nil,
                description: "Immediate and urgent support. Call 215-898-HELP if you are worried about a friend — trained staff will help you navigate next steps."
            )
        ]
    ),
    WellnessCategory(
        name: "Sexual Violence & Relationship Safety",
        sfSymbol: "heart",
        resources: [
            WellnessResource(
                name: "Penn Violence Prevention (PVP)",
                callActions: [("Call 215-746-2642 (24/7 confidential)", "2157462642")],
                websiteURL: "https://pvp.universitylife.upenn.edu",
                locationLabel: nil,
                emailAddress: nil,
                description: "Confidential support and advocacy for students impacted by sexual assault, domestic violence, stalking, or harassment. Provides safety planning, accompaniment to medical, legal, or reporting appointments, and referrals to ongoing counseling."
            ),
            WellnessResource(
                name: "Division of Public Safety (DPS) Special Services",
                callActions: [("Call 215-898-6600 (24/7)", "2158986600")],
                websiteURL: nil,
                locationLabel: nil,
                emailAddress: nil,
                description: "24/7 support after an incident, including accompaniment to hospitals or police stations. No appointment necessary — call anytime, even if you are unsure what to do."
            ),
            WellnessResource(
                name: "Penn Women's Center (PWC)",
                callActions: [("Call 215-898-8611 (24/7)", "2158988611")],
                websiteURL: "https://pwc.universitylife.upenn.edu",
                locationLabel: "3643 Locust Walk",
                emailAddress: nil,
                description: "Support and advocacy for gender-based harm. Drop by in person any time or visit the website to plan a visit."
            ),
            WellnessResource(
                name: "STTOP Team (Sexual Trauma Treatment)",
                callActions: [],
                websiteURL: nil,
                locationLabel: nil,
                emailAddress: nil,
                description: "Specialized trauma care. Ask your CAPS clinician for a referral or contact CAPS directly and request a STTOP appointment."
            )
        ]
    ),
    WellnessCategory(
        name: "Safety & Security",
        sfSymbol: "key",
        resources: [
            WellnessResource(
                name: "Division of Public Safety (DPS)",
                callActions: [("Call 215-573-3333 (24/7 emergency)", "2155733333")],
                websiteURL: nil,
                locationLabel: "4040 Chestnut St",
                emailAddress: nil,
                description: "Report crimes, request campus escorts (call 215-898-9255), mark lost items, and register for community education programs."
            ),
            WellnessResource(
                name: "Campus Help Line",
                callActions: [("Call 215-898-4357 (24/7)", "2158984357")],
                websiteURL: nil,
                locationLabel: nil,
                emailAddress: nil,
                description: "24/7 guidance and resource connection for safety, housing, wellness, and referrals."
            )
        ]
    ),
    WellnessCategory(
        name: "Physical Health",
        sfSymbol: "dumbbell",
        resources: [
            WellnessResource(
                name: "Student Health Service",
                callActions: [("Call 215-746-9355 (24/7)", "2157469355")],
                websiteURL: "https://wellness.upenn.edu/student-health-counseling/medical-care",
                locationLabel: "3535 Market St, Suite 100",
                emailAddress: nil,
                description: "General medical care, urgent care, sexual and reproductive health, immunizations, sports medicine, travel medicine, and preventative care. Walk-in hours may be available — check the website for current times."
            )
        ]
    ),
    WellnessCategory(
        name: "Religious & Spiritual",
        sfSymbol: "building.columns",
        resources: [
            WellnessResource(
                name: "Office of the Chaplain",
                callActions: [("Call 215-898-8456", "2158988456")],
                websiteURL: "https://chaplain.upenn.edu",
                locationLabel: "118 S 37th Street",
                emailAddress: nil,
                description: "Faith and spiritual care for students of any belief. Check the website for available hours before visiting in person."
            )
        ]
    ),
    WellnessCategory(
        name: "Tutoring and Accessibility",
        sfSymbol: "book",
        resources: [
            WellnessResource(
                name: "Weingarten Center",
                callActions: [],
                websiteURL: "https://markscenter.sas.upenn.edu/writing-center/schedule-appointment",
                locationLabel: nil,
                emailAddress: nil,
                description: "Academic support including private, group, and drop-in tutoring. Accessibility accommodations (extended time, note-taking, flexible attendance). Learning strategies, study skills coaching, and executive functioning support. You do not need to be failing a class to register."
            ),
            WellnessResource(
                name: "Language Center",
                callActions: [],
                websiteURL: "https://plc.sas.upenn.edu",
                locationLabel: nil,
                emailAddress: nil,
                description: "One-on-one language consultations covering pronunciation, presentation, academic English, and discipline-specific language. Supports writing, speaking, and listening development. Bring a draft, a presentation, or questions."
            ),
            WellnessResource(
                name: "Writing Center",
                callActions: [],
                websiteURL: "https://writing.upenn.edu/critical/wc",
                locationLabel: nil,
                emailAddress: nil,
                description: "Writing help at any stage, from brainstorming to polishing a final draft. Feedback on essays, lab reports, theses, and personal statements covering structure, clarity, argument, and flow. Early ideas are welcome — no finished draft needed."
            )
        ]
    ),
    WellnessCategory(
        name: "Legal",
        sfSymbol: "hammer",
        resources: [
            WellnessResource(
                name: "UA Legal Services",
                callActions: [],
                websiteURL: nil,
                locationLabel: nil,
                emailAddress: "legal@pennua.org",
                description: "One-on-one appointments with Penn attorneys for housing and landlord disputes, food and government benefits, healthcare insurance and medical bills, and immigration, visa, and employment assistance. Email to schedule an appointment."
            )
        ]
    )
]

// MARK: - Main View

struct WellnessView: View {
    @State private var expandedCategoryId: UUID?

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                headerImage
                mainContent
            }
        }
        .ignoresSafeArea(edges: .top)
        .background(Color(.systemBackground))
    }

    private var headerImage: some View {
        Image("CollegeHall")
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(height: 180)
            .clipped()
    }

    private var mainContent: some View {
        VStack(alignment: .leading, spacing: 0) {
            uaHeaderRow
            Divider().padding(.horizontal)
            descriptionText
            categoryListView
        }
        .background(Color(.systemBackground))
    }

    private var uaHeaderRow: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color("baseDarkBlue"))
                    .frame(width: 44, height: 44)
                Text("UA")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text("Undergraduate Assembly")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Text("Student resources")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()
            
            if let url = URL(string: "https://sites.google.com/view/undergraduate-assembly/home") {
                NavigationLink(destination: WebView(url: url)) {
                    Image(systemName: "arrow.up.right")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(PlainButtonStyle())
            }

        }
        .padding()
    }

    private var descriptionText: some View {
        Text("This guide outlines the various resources and support available to Penn students, including when to use them and how to access them.")
            .font(.subheadline)
            .foregroundStyle(.secondary)
            .padding()
    }

    private var categoryListView: some View {
        VStack(spacing: 0) {
            ForEach(wellnessCategories) { category in
                CategoryRowView(
                    category: category,
                    isExpanded: expandedCategoryId == category.id,
                    onToggle: {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            expandedCategoryId = expandedCategoryId == category.id ? nil : category.id
                        }
                    }
                )
                if category.id != wellnessCategories.last?.id {
                    Divider()
                }
            }
        }
    }
}

// MARK: - Category Row

struct CategoryRowView: View {
    let category: WellnessCategory
    let isExpanded: Bool
    let onToggle: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Button(action: onToggle) {
                HStack(spacing: 14) {
                    Image(systemName: category.sfSymbol)
                        .frame(width: 22, alignment: .center)
                        .foregroundStyle(.primary)

                    Text(category.name)
                        .font(.body)
                        .foregroundStyle(.primary)
                        .multilineTextAlignment(.leading)

                    Spacer()

                    Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal)
                .padding(.vertical, 16)
                .frame(maxWidth: .infinity)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            if isExpanded && !category.resources.isEmpty {
                VStack(spacing: 8) {
                    ForEach(category.resources) { resource in
                        ResourceCardView(resource: resource)
                    }
                }
                .padding(.vertical, 8)
                .background(Color(.systemGroupedBackground))
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }
}

// MARK: - Resource Card

struct ResourceCardView: View {
    let resource: WellnessResource

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(resource.name)
                .font(.subheadline)
                .fontWeight(.bold)

            ForEach(resource.callActions, id: \.label) { action in
                CallActionButton(label: action.label, number: action.number)
            }

            let hasLinks = resource.websiteURL != nil || resource.locationLabel != nil || resource.emailAddress != nil
            if hasLinks {
                HStack(spacing: 8) {
                    if let url = resource.websiteURL {
                        LinkPillButton(label: "Website", icon: "arrow.up.right", destination: url)
                    }
                    if let location = resource.locationLabel {
                        LinkPillButton(label: "Location", icon: "mappin", destination: "https://maps.apple.com/?q=\(location.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")")
                    }
                    if let email = resource.emailAddress {
                        LinkPillButton(label: "Email", icon: "envelope.fill", destination: "mailto:\(email)")
                    }
                }
            }

            Text(resource.description)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal)
    }
}

// MARK: - Button Components

struct CallActionButton: View {
    let label: String
    let number: String
    @Environment(\.openURL) private var openURL

    var body: some View {
        Button {
            if let url = URL(string: "tel://\(number)") {
                openURL(url)
            }
        } label: {
            HStack(spacing: 6) {
                Text(label)
                    .font(.caption)
                    .fontWeight(.medium)
                Image(systemName: "phone.fill")
                    .font(.caption2)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.blue.opacity(0.12))
            .foregroundStyle(Color.blue)
            .clipShape(Capsule())
        }
    }
}

struct LinkPillButton: View {
    let label: String
    let icon: String
    let destination: String
    @Environment(\.openURL) private var openURL

    var body: some View {
        Button {
            if let url = URL(string: destination) {
                openURL(url)
            }
        } label: {
            HStack(spacing: 4) {
                Text(label)
                Image(systemName: icon)
                    .font(.caption2)
            }
            .font(.caption)
            .fontWeight(.medium)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color(.systemFill))
            .foregroundStyle(.primary)
            .clipShape(Capsule())
        }
    }
}

// MARK: - Preview

#Preview {
    WellnessView()
}
