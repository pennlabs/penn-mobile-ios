//
//  NotificationsViewModel.swift
//  PennMobile
//
//  Created by Raunaq Singh on 9/25/22.
//  Copyright © 2022 PennLabs. All rights reserved.
//

import SwiftUI
import UserNotifications
import PennMobileShared

@MainActor
@Observable
class NotificationsViewModel {
    var settings: BackendFetchedResult<[NotificationSetting]> = .pending
    var authorizationStatus: UNAuthorizationStatus?

    init() {}

    func load() async {
        async let fetched = PennMobileApplication.Notifications.GetNotificationSettings().execute()
        let status = await UNUserNotificationCenter.current().notificationSettings().authorizationStatus

        authorizationStatus = status
        if status == .authorized {
            UIApplication.shared.registerForRemoteNotifications()
        }
        settings = await fetched
    }

    // Optimistically flips the toggle, reverting if the endpoint fails (it shows its own toast)
    func setEnabled(_ settingId: Int, _ enabled: Bool) async {
        guard case .success(var current) = settings,
              let index = current.firstIndex(where: { $0.id == settingId }) else { return }

        let setting = current[index]
        current[index].enabled = enabled
        settings = .success(current)

        let result = await PennMobileApplication.Notifications.UpdateNotificationSetting(
            id: setting.id,
            service: setting.service.rawValue,
            enabled: enabled
        ).execute()

        if case .failure = result,
           case .success(var latest) = settings,
           let index = latest.firstIndex(where: { $0.id == settingId }) {
            latest[index].enabled = setting.enabled
            settings = .success(latest)
        }
    }

    func requestAuthorization() async -> Bool {
        let granted = (try? await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound])) ?? false
        authorizationStatus = granted ? .authorized : .denied
        if granted {
            UIApplication.shared.registerForRemoteNotifications()
        }
        return granted
    }
}
