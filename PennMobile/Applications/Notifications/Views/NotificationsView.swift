//
//  NotificationsView.swift
//  PennMobile
//
//  Created by Raunaq Singh on 9/25/22.
//  Copyright © 2022 PennLabs. All rights reserved.
//

import SwiftUI
import PennMobileShared
import UserNotifications

struct NotificationsView: View {
    @State var vm = NotificationsViewModel()
    @Environment(\.dismiss) var dismiss
    @Environment(\.openURL) var openURL

    var body: some View {
        Form {
            switch vm.settings {
            case .pending:
                ProgressView()
                    .frame(maxWidth: .infinity)
            case .failure:
                ContentUnavailableView("Unable to Load Notification Settings", systemImage: "bell.slash")
            case .success(let settings):
                ForEach(settings.filter { NotificationPreference.visibleOptions.contains($0.service) }) { setting in
                    Section {
                        Toggle(setting.service.title, isOn: Binding {
                            setting.enabled
                        } set: { enabled in
                            Task { await vm.setEnabled(setting.id, enabled) }
                        })
                    } footer: {
                        Text(setting.service.description)
                    }
                }
            }
        }
        .task {
            await vm.load()
        }
        .alert("Enable Notifications", isPresented: isPresented(for: .notDetermined)) {
            Button("Don't Allow") { dismiss() }
            Button("OK") {
                Task {
                    if !(await vm.requestAuthorization()) {
                        dismiss()
                    }
                }
            }
        } message: {
            Text("Receive Penn Course Alert notifications (when available), laundry alerts, and information about new features.")
        }
        .alert("Turn On Notifications", isPresented: isPresented(for: .denied)) {
            Button("Don't Allow") { dismiss() }
            Button("Allow") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    openURL(url)
                }
            }
        } message: {
            Text("Go to Settings -> Notifications -> PennMobile -> Allow Notifications.")
        }
    }

    // Alerts are dismissed by clearing the status, so they don't re-present on every redraw
    private func isPresented(for status: UNAuthorizationStatus) -> Binding<Bool> {
        Binding {
            vm.authorizationStatus == status
        } set: { isPresented in
            if !isPresented { vm.authorizationStatus = nil }
        }
    }
}
