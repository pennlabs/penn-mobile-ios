//
//  NotificationsView.swift
//  PennMobile
//
//  Created by Raunaq Singh on 9/25/22.
//  Copyright © 2022 PennLabs. All rights reserved.
//

import SwiftUI

struct NotificationsView: View, NotificationRequestable {
    @State var areNotificationsEnabled = false
    @State var areNotificationsUndetermined = false
    @State var areNotificationsDenied = false
    @Environment(\.dismiss) var dismiss

    @StateObject var notificationViewModel = NotificationViewModel.instance
    @StateObject var shouldShowError = NotificationViewModel.instance

    var body: some View {
        Form {
            ForEach($notificationViewModel.notificationSettings) { $setting in
                if NotificationType.visibleOptions.contains(setting.service) {
                    Section(footer: Text(setting.service.description)) {
                        Toggle(setting.service.title, isOn: $setting.enabled)
                            .onChange(of: $setting.enabled.wrappedValue) { value in
                                Task.init(operation: { await notificationViewModel.requestChange(service: setting, toValue: value) })
                            }
                    }
                }
            }
        }.onAppear {
            if !Account.isLoggedIn {
                notificationViewModel.shouldShowError = true
            }

            UNUserNotificationCenter.current().getNotificationSettings(completionHandler: { (settings) in
                if settings.authorizationStatus == .notDetermined {
                    areNotificationsUndetermined = true
                    notificationViewModel.shouldShowError = true
                } else if settings.authorizationStatus == .denied {
                    areNotificationsDenied = true
                    notificationViewModel.shouldShowError = true
                } else if settings.authorizationStatus == .authorized {
                    areNotificationsEnabled = true
                    DispatchQueue.main.async {
                        UIApplication.shared.registerForRemoteNotifications()
                    }
                }
            })
        }.alert(isPresented: $notificationViewModel.shouldShowError) {
            showError()
        }.task {
            await notificationViewModel.fetchNotificationSettings()
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
}

struct NotificationsView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationsView()
    }
}
