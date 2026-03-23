//
//  Incidents.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 3/23/26.
//  Copyright © 2026 PennLabs. All rights reserved.
//

import SwiftUI
import PennMobileShared
import Combine

class IncidentsViewModel: ObservableObject {
    @Published var incidents: [Incident]
    var labelStyle: IncidentAwareLabelStyle? {
        return IncidentAwareLabelStyle(with: incidents)
    }
    
    var mostSignificantIncident: Incident? {
        return incidents.sorted(by: { $0.severity.rawValue > $1.severity.rawValue}).first
    }
    
    static let shared = IncidentsViewModel()
    
    let timer = Timer.publish(every: 60 * 2, on: .main, in: .default).autoconnect()
    var updateCancellable: (any Cancellable)? = nil
    
    init() {
        incidents = []
    }
    
    deinit {
        self.updateCancellable?.cancel()
        self.updateCancellable = nil
    }
    
    @MainActor func startUpdatePolling() {
        self.updateCancellable = timer.sink { _ in
            Task { @MainActor in
                try? await self.getIncidents()
            }
        }
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
        }.sorted(by: { $0.severity.rawValue > $1.severity.rawValue })
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

