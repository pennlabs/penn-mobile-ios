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

    var body: some View {
        if Account.isLoggedIn {
            Form {
                ForEach($notificationSettings) { $setting in
                    if NotificationSetting.visibleOptions.contains($setting.id) {
                        Section(footer: Text(setting.description!)) {
                            Toggle(setting.title!, isOn: $setting.enabled)
                        }
                    }
                }
            }.task {
                UserDBManager.shared.fetchNotificationSettings { result in
                    if let notifSettings = try? result.get() {
                        notificationSettings = notifSettings
                    }
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
