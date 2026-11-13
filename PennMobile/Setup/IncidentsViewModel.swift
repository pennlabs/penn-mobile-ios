//
//  IncidentsViewModel.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 3/23/26.
//  Copyright © 2026 PennLabs. All rights reserved.
//

import SwiftUI
import PennMobileShared

// App-wide like PennMobileAuthManager: incidents keep refreshing whether or not
// the More tab is on screen, and the tab bar label reflects them.
@MainActor
@Observable
class IncidentsViewModel {
    static let shared = IncidentsViewModel()

    private(set) var incidents: [Incident] = []

    // General polling every 15 minutes, more frequently while there's an active incident
    private static let pollingInterval: Duration = .seconds(60 * 15)
    private static let highPriorityPollingInterval: Duration = .seconds(60 * 2)

    var labelStyle: IncidentAwareLabelStyle {
        IncidentAwareLabelStyle(with: incidents)
    }

    var mostSignificantIncident: Incident? {
        incidents.first
    }

    private init() {}

    /// Fetches immediately, then every 15 minutes (2 while any incident is active) until the calling task is cancelled.
    func startUpdatePolling() async {
        while !Task.isCancelled {
            await getIncidents()
            try? await Task.sleep(for: incidents.isEmpty ? Self.pollingInterval : Self.highPriorityPollingInterval)
        }
    }

    // Background fetch, so failures are silent and keep the last known incidents
    func getIncidents() async {
        if case .success(let all) = await PennMobileApplication.Incidents.GetIncidents().execute(shouldSilentlyFail: true) {
            incidents = all.relevant
        }
    }
}

struct IncidentAwareLabelStyle: LabelStyle {
    let toggle: IncidentLabelStyleToggle

    init(with incidents: [Incident]) {
        guard let highest = incidents.max(by: { $0.severity.rawValue < $1.severity.rawValue }) else {
            self.toggle = .disabled
            return
        }
        self.toggle = .enabled(color: highest.severity.color, systemName: highest.severity.systemImage)
    }

    func makeBody(configuration: Configuration) -> some View {
        if case .enabled(let color, let systemName) = toggle {
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
        } else {
            Label(title: { configuration.title }, icon: { configuration.icon })
        }
    }

    enum IncidentLabelStyleToggle {
        case enabled(color: Color, systemName: String)
        case disabled
    }
}
