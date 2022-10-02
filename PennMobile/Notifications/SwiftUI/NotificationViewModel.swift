//
//  NotificationViewModel.swift
//  PennMobile
//
//  Created by Raunaq Singh on 10/2/22.
//  Copyright © 2022 PennLabs. All rights reserved.
//

import Foundation

class NotificationViewModel: ObservableObject {
    static let instance = NotificationViewModel()

    @Published var notificationSettings: [NotificationSetting] = []
    @Published var shouldShowError = false

    func fetchNotificationSettings() async {
        UserDBManager.shared.fetchNotificationSettings { result in
            if let notifSettings = try? result.get() {
                self.notificationSettings = notifSettings
            }
        }
    }

    func requestChange(service: NotificationSetting, toValue: Bool) async {
        UserDBManager.shared.updateNotificationSetting(service: service.id.rawValue, enabled: toValue) { result in
            if !result {
                self.shouldShowError = true
            }
        }
    }
}
