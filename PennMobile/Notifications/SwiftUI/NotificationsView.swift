//
//  NotificationsView.swift
//  PennMobile
//
//  Created by Raunaq Singh on 9/25/22.
//  Copyright © 2022 PennLabs. All rights reserved.
//

import SwiftUI

struct NotificationsView: View, NotificationRequestable {
    @State var notificationSettings: [NotificationSetting] = []
    @State var shouldShowError = false
    @State var areNotificationsEnabled = false
    @State var areNotificationsUndetermined = false
    @State var areNotificationsDenied = false
    @Environment(\.dismiss) var dismiss

    var body: some View {
        Form {
            ForEach($notificationSettings) { $setting in
                if NotificationPreference.visibleOptions.contains($setting.id) {
                    Section(footer: Text($setting.id.description)) {
                        Toggle($setting.id.title, isOn: $setting.enabled)
                            .onChange(of: $setting.enabled.wrappedValue) { value in
                                requestChange(service: $setting.id.rawValue, toValue: value)
                            }
                    }
                }
            }
        }.onAppear {
            if !Account.isLoggedIn {
                shouldShowError = true
            }
            #if !targetEnvironment(simulator)
            UNUserNotificationCenter.current().getNotificationSettings(completionHandler: { (settings) in
                if settings.authorizationStatus == .notDetermined {
                    areNotificationsUndetermined = true
                    shouldShowError = true
                } else if settings.authorizationStatus == .denied {
                    areNotificationsDenied = true
                    shouldShowError = true
                } else if settings.authorizationStatus == .authorized {
                    areNotificationsEnabled = true
                    DispatchQueue.main.async {
                        UIApplication.shared.registerForRemoteNotifications()
                    }
                }
            })
            #endif
        }.alert(isPresented: $shouldShowError) {
            showError()
        }.task {
            UserDBManager.shared.fetchNotificationSettings { result in
                if let notifSettings = try? result.get() {
                    notificationSettings = notifSettings
                } else {
                    shouldShowError = true
                }
            }
        }
    }
}

extension NotificationsView {
    func showError() -> Alert {
        if !Account.isLoggedIn {
            return showLoginError()
        } else if areNotificationsDenied {
            return showNotificationsDeniedError()
        } else if areNotificationsUndetermined {
            return showNotificationsUndeterminedError()
        }
        return Alert(title: Text("Unexpected Error"), message: Text("Please make sure you have an internet connection and try again."), dismissButton: .default(Text("Ok"), action: { dismiss() }))
    }

    func showLoginError() -> Alert {
        return Alert(title: Text("Login Required"), message: Text("Please login on the \"More\" tab to access this feature."), dismissButton: .default(Text("Ok"), action: { dismiss() }))
    }

    func showNotificationsUndeterminedError() -> Alert {
        return Alert(title: Text("Enable Notifications"), message: Text("Receive monthly dining plan progress updates, laundry alerts, and information about new features."), primaryButton: .default(Text("Don't Allow"), action: { dismiss() }), secondaryButton: .default(Text("OK"), action: {
                registerPushNotification { (granted) in
                    DispatchQueue.main.async {
                        if granted {
                            areNotificationsEnabled = true
                            areNotificationsUndetermined = false
                            areNotificationsDenied = false
                        } else {
                            dismiss()
                        }
                    }
                }
            }
        ))
    }

    func showNotificationsDeniedError() -> Alert {
        return Alert(title: Text("Turn On Notifications"), message: Text("Go to Settings -> Notifications -> PennMobile -> Allow Notifications."), primaryButton: .default(Text("Don't Allow"), action: { dismiss() }), secondaryButton: .default(Text("Allow"), action: {
                if let appSettings = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(appSettings) {
                    UIApplication.shared.open(appSettings)
                }
            }
        ))
    }

    func requestChange(service: String, toValue: Bool) {
        UserDBManager.shared.updateNotificationSetting(service: service, enabled: toValue) { result in
            if !result {
                shouldShowError = true
            }
        }
    }

}

struct NotificationsView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationsView()
    }
}
