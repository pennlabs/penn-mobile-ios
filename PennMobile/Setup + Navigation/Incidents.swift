//
//  Incidents.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 3/23/26.
//  Copyright © 2026 PennLabs. All rights reserved.
//

import SwiftUI

class IncidentsViewModel: ObservableObject {
    @Published var incidents: [Incident]
    var labelStyle: IncidentAwareLabelStyle? {
        return IncidentAwareLabelStyle(with: incidents)
    }
    
    static let shared = IncidentsViewModel()
    
    init() {
        incidents = []
    }
    
    @MainActor func getIncidents() async throws {
        let url = URL(string: "https://status.pennlabs.org/incidents.json")!
        let (data, _) = try await URLSession.shared.data(from: url)
        let dec = JSONDecoder()
        dec.keyDecodingStrategy = .convertFromSnakeCase
        dec.dateDecodingStrategy = .iso8601
        let incidents = try dec.decode([Incident].self, from: data)
        self.incidents = incidents.filter { el in
            let isBackend = el.affectedServices.contains("mobile-backend")
            let isResolved = el.status == "resolved"
            return isBackend && !isResolved
        }
    }
    
    struct IncidentAwareLabelStyle: LabelStyle {
        let color: Color
        let systemName: String
        
        init?(with incidents: [Incident]) {
            guard !incidents.isEmpty else { return nil }
            let highest = incidents.max(by: { $0.severity.rawValue < $1.severity.rawValue })!
            self.color = highest.severity.color
            self.systemName = highest.severity.systemImage
        }
        
        func makeBody(configuration: Configuration) -> some View {
            Label(title: { configuration.title }, icon: {
                if #available(iOS 18.0, *) {
                    Image(systemName: systemName)
                        .foregroundStyle(.white, color)
                        .symbolEffect(.wiggle.byLayer, options: .repeat(.periodic(delay: 3.0)))
                } else {
                    Image(systemName: systemName)
                        .foregroundStyle(.white, color)
                }
            })
        }
    }
}



struct Incident: Identifiable, Codable {
    let id: String
    let title: String
    let createdAt: Date
    let affectedServices: [String]
    let status: String
    let severity: IncidentSeverity
    let updates: [IncidentUpdate]
}

struct IncidentUpdate: Identifiable, Codable {
    let id: String
    let message: String
    let status: String
    let timestamp: Date
}

struct IncidentView: View {
    let incident: Incident

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack(spacing: 12) {
                Image(systemName: incident.severity.systemImage)
                    .foregroundStyle(.white, incident.severity.color)
                    .font(.title2)

                VStack(alignment: .leading, spacing: 2) {
                    Text(incident.title)
                        .font(.headline)
                    Text(incident.status.capitalized)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            // Timeline
            if !incident.updates.isEmpty {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(Array(incident.updates.enumerated()), id: \.element.id) { index, update in
                        HStack(alignment: .top, spacing: 12) {
                            // Dot + connecting line
                            VStack(spacing: 0) {
                                Circle()
                                    .fill(incident.severity.color)
                                    .frame(width: 8, height: 8)
                                    .padding(.top, 5)
                                if index < incident.updates.count - 1 {
                                    Rectangle()
                                        .fill(Color.secondary.opacity(0.25))
                                        .frame(width: 2)
                                        .frame(maxHeight: .infinity)
                                }
                            }
                            .frame(width: 8)

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

enum IncidentSeverity: Int, Codable {
    case severe = 2
    case degraded = 1
    case info = 0
    
    
    var systemImage: String {
        switch self {
        case .severe:
            "xmark.octagon.fill"
        case .degraded:
            "exclamationmark.triangle.fill"
        case .info:
            "info.circle.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .severe:
                .red
        case .degraded:
                .yellow
        case .info:
                .gray
        }
    }
    
    
}

