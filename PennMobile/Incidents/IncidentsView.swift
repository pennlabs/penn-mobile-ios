//
//  IncidentsView.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 3/23/26.
//  Copyright © 2026 PennLabs. All rights reserved.
//

import SwiftUI

struct IncidentView: View {
    let incident: Incident

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .center, spacing: 12) {
                Image(systemName: incident.severity.systemImage)
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(.white, incident.severity.color)
                    .frame(width: 32)
                    
                VStack(alignment: .leading, spacing: 2) {
                    Text(incident.title)
                        .font(.headline)
                    Text(incident.status.capitalized)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            if !incident.updates.isEmpty {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(Array(incident.updates.enumerated()), id: \.element.id) { index, update in
                        HStack(alignment: .top, spacing: 12) {
                            // Dot + connecting line
                            VStack(spacing: 0) {
                                Circle()
                                    .fill(incident.severity.color)
                                    .frame(width: 8, height: 8)
                                    .padding(.vertical, 5)
                                if index < incident.updates.count - 1 {
                                    Rectangle()
                                        .fill(Color.secondary.opacity(0.25))
                                        .frame(width: 2)
                                        .frame(maxHeight: .infinity)
                                }
                            }
                            .frame(width: 8)
                            .padding(.horizontal, 12)

                            VStack(alignment: .leading, spacing: 3) {
                                Text(update.message)
                                    .font(.subheadline)
                                Text(update.timestamp, style: .relative)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.bottom, index < incident.updates.count - 1 ? 14 : 0)
                        }
                    }
                }
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    IncidentView(incident: .init(
        id: "debug-severe",
        title: "Service Outage",
        createdAt: Date().addingTimeInterval(-7200),
        affectedServices: ["mobile-backend"],
        status: "investigating",
        severity: .severe,
        updates: [
            .init(id: "debug-severe-3", message: "A fix has been deployed and we are monitoring the situation.", status: "monitoring", timestamp: Date().addingTimeInterval(-1200)),
            .init(id: "debug-severe-2", message: "The issue has been identified. Services are currently unavailable.", status: "identified", timestamp: Date().addingTimeInterval(-5400)),
            .init(id: "debug-severe-1", message: "We are investigating a critical service outage.", status: "investigating", timestamp: Date().addingTimeInterval(-7200))
        ]
    ))
}
