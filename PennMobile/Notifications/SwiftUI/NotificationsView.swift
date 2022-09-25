//
//  NotificationsViewSwiftUI.swift
//  PennMobile
//
//  Created by Raunaq Singh on 9/25/22.
//  Copyright © 2022 PennLabs. All rights reserved.
//

import SwiftUI

struct NotificationsView: View {
    @State var notificationSettings: [NotificationSetting] = []
    @State var notificationsEnabled = true
    @State var isError = false
    @Environment(\.presentationMode) var presentationMode

    func showError () -> Alert {
        if !Account.isLoggedIn {
            return Alert(title: Text("You must log in to access this feature."), message: Text("Please login on the \"More\" tab."), dismissButton: .default(Text("Ok"), action: { presentationMode.wrappedValue.dismiss() }))
        } else {
            return Alert(title: Text("You must enable notifications to access this feature."), message: Text("Go to Settings -> Notifications -> PennMobile -> Allow Notifications."), dismissButton: .default(Text("Ok"), action: { presentationMode.wrappedValue.dismiss() }))
        }
    }

    var body: some View {
        Form {
            if Account.isLoggedIn && notificationsEnabled {
                ForEach($notificationSettings) { $setting in
                    if NotificationSetting.visibleOptions.contains($setting.id) {
                        Section(footer: Text(setting.description!)) {
                            Toggle(setting.title!, isOn: $setting.enabled)
                                .onChange(of: setting.enabled) { value in
                                    UserDBManager.shared.updateNotificationSetting(service: $setting.id, enabled: value) { result in
                                        print(result)
                                    }
                                }
                        }
                    }
                }
            }
        }.onAppear {
            #if !targetEnvironment(simulator)
            UNUserNotificationCenter.current().getNotificationSettings(completionHandler: { (settings) in
                if settings.authorizationStatus == .notDetermined || settings.authorizationStatus == .denied {
                    DispatchQueue.main.async {
                        // Notification access not granted.
                        notificationsEnabled = false
                    }
                }
            })
            #endif

            if !notificationsEnabled || !Account.isLoggedIn {
                isError = true
            }
        }.alert(isPresented: $isError) {
            showError()
        }.task {
            UserDBManager.shared.fetchNotificationSettings { result in
                if let notifSettings = try? result.get() {
                    notificationSettings = notifSettings
                }
            }
        }
    }
}

extension NotificationsView {}

struct NotificationsView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationsView()
    }
}
