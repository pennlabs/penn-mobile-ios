//
//  LaundryAlarmService.swift
//  PennMobile
//
//  Created by Nathan Aronson on 11/21/25.
//  Copyright © 2025 PennLabs. All rights reserved.
//

import AlarmKit
import SwiftUI
import UserNotifications
#if canImport(ActivityKit)
import ActivityKit
#endif
import PennMobileShared

@MainActor
protocol LaundryAlarmHandler {
    func subscribe(to machine: MachineDetail, and hallName: String)
    func unsubscribe(from machine: MachineDetail)
    func fetchAlarms()
    func containsAlarm(for machineID: String) -> Bool
}

enum LaundryAlarmService {
    @MainActor static func makeHandler() -> LaundryAlarmHandler {
        if #available(iOS 26.0, *) {
            return AlarmKitAlarmHandler()
        }
        
        return FallbackAlarmHandler()
    }
}

@available(iOS 26.0, *)
extension AlarmButton {
    static var stopButton: Self {
        AlarmButton(text: "Done", textColor: .white, systemImageName: "stop.circle")
    }
}

extension MachineDetail.MachineType {
    var label: LocalizedStringResource {
        switch self {
        case .washer: LocalizedStringResource("Washer")
        case .dryer: LocalizedStringResource("Dryer")
        }
    }
}


@available(iOS 26.0, *)
@Observable final class AlarmKitAlarmHandler: LaundryAlarmHandler {
    
    typealias AlarmConfiguration = AlarmManager.AlarmConfiguration<MachineData>
    typealias AlarmsMap = [UUID: (Alarm, LocalizedStringResource)]
    
    @MainActor var alarmsMap = AlarmsMap()
    @ObservationIgnored private let alarmManager = AlarmManager.shared
    
    @ObservationIgnored
    @AppStorage("machineAlarmMapping")
    private var data: Data = Data()
    
    @MainActor var machineAlarmMapping: [String: UUID] = [:] {
        didSet {
            if let encoded = try? JSONEncoder().encode(machineAlarmMapping) {
                data = encoded
            }
        }
    }
    
    @MainActor var hasUpcomingAlerts: Bool {
        !alarmsMap.isEmpty
    }
    
    init() {
        Task { @MainActor in
            if let decoded = try? JSONDecoder().decode([String: UUID].self, from: data) {
                self.machineAlarmMapping = decoded
            }
            
            self.fetchAlarms()
        }
        observeAlarms()
    }
    
    @MainActor func containsAlarm(for machineID: String) -> Bool {
        guard let id = machineAlarmMapping[machineID] else { return false }
        return alarmsMap[id] != nil
    }
    
    private func observeAlarms() {
        Task {
            for await incomingAlarms in alarmManager.alarmUpdates {
                updateAlarmState(with: incomingAlarms)
            }
        }
    }
    
    private func updateAlarmState(with remoteAlarms: [Alarm]) {
        Task { @MainActor in
            
            remoteAlarms.forEach { updated in
                alarmsMap[updated.id, default: (updated, "Alarm (Old Session)")].0 = updated
            }
            
            let knownAlarmIDs = Set(alarmsMap.keys)
            let incomingAlarmIDs = Set(remoteAlarms.map(\.id))
            
            for (machineID, alarmID) in machineAlarmMapping where !incomingAlarmIDs.contains(alarmID) {
                machineAlarmMapping[machineID] = nil
            }
            
            let removedAlarmIDs = Set(knownAlarmIDs.subtracting(incomingAlarmIDs))
            removedAlarmIDs.forEach { alarmID in
                alarmsMap[alarmID] = nil
                
                if let machineID = machineAlarmMapping.first(where: { $0.value == alarmID })?.key {
                    machineAlarmMapping[machineID] = nil
                }
            }
        }
    }
    
    private func requestAuthorization() async -> Bool {
        switch alarmManager.authorizationState {
        case .notDetermined:
            do {
                let state = try await alarmManager.requestAuthorization()
                return state == .authorized
            } catch {
                print("Error occurred while requesting authorization: \(error)")
                return false
            }
        case .denied: return false
        case .authorized: return true
        @unknown default: return false
        }
    }
    
    func subscribe(to machine: MachineDetail, and hallName: String) {
        Task { @MainActor in
            let alertContent = AlarmPresentation.Alert(title: LocalizedStringResource("\(machine.type.label) Ready"),
                                                       stopButton: .stopButton,
                                                       secondaryButton: nil,
                                                       secondaryButtonBehavior: nil)
            
            let countdownContent = AlarmPresentation.Countdown(title: machine.type.label)
            
            let alarmPresentation = AlarmPresentation(alert: alertContent, countdown: countdownContent, paused: nil)
            
            let attributes = AlarmAttributes<MachineData>(presentation: alarmPresentation, metadata: MachineData(hallName: hallName, machine: machine), tintColor: Color.accentColor)
            
            let id = machineAlarmMapping[machine.id] ?? UUID()
            
            machineAlarmMapping[machine.id] = id
            
            let time = TimeInterval(machine.timeRemaining * 60)
            
            let alarmConfiguration = AlarmConfiguration(countdownDuration: .init(preAlert: time, postAlert: time), attributes: attributes)
            
            scheduleAlarm(id: id, label: LocalizedStringResource(stringLiteral: hallName), alarmConfiguration: alarmConfiguration)
        }
    }
    
    private func scheduleAlarm(id: UUID, label: LocalizedStringResource, alarmConfiguration: AlarmConfiguration) {
        Task {
            do {
                guard await requestAuthorization() else {
                    print("Not authorized to schedule alarms.")
                    return
                }
                let alarm = try await alarmManager.schedule(id: id, configuration: alarmConfiguration)
                await MainActor.run {
                    alarmsMap[id] = (alarm, label)
                }
            } catch {
                print("Error encountered when scheduling alarm: \(error)")
            }
        }
    }
    
    func fetchAlarms() {
        do {
            let remoteAlarms = try alarmManager.alarms
            updateAlarmState(with: remoteAlarms)
        } catch {
            print("Error fetching alarms: \(error)")
        }
    }
    
    func unsubscribe(from machine: MachineDetail) {
        Task { @MainActor in
            if let id = machineAlarmMapping[machine.id] {
                try? alarmManager.cancel(id: id)
                alarmsMap[id] = nil
                
                machineAlarmMapping[machine.id] = nil
            }
        }
    }
}

@Observable final class FallbackAlarmHandler: LaundryAlarmHandler {
    
    @ObservationIgnored private let center = UNUserNotificationCenter.current()
    
    @ObservationIgnored
    @AppStorage("machineNotificationMapping")
    private var notificationData: Data = Data()
    
    @ObservationIgnored
    @AppStorage("subscribedMachines")
    private var subscribedMachinesData: Data = Data()
    
    @MainActor var machineNotificationMapping: [String: String] = [:] {
        didSet {
            if let encoded = try? JSONEncoder().encode(machineNotificationMapping) {
                notificationData = encoded
            }
        }
    }
    
    @MainActor var subscribedMachineIDs: Set<String> = [] {
        didSet {
            if let encoded = try? JSONEncoder().encode(Array(subscribedMachineIDs)) {
                subscribedMachinesData = encoded
            }
        }
    }
    
    @MainActor private var pendingRequestIDs: Set<String> = []
    
    init() {
        Task { @MainActor in
            if let decoded = try? JSONDecoder().decode([String: String].self, from: notificationData) {
                self.machineNotificationMapping = decoded
            }
            if let decodedSubs = try? JSONDecoder().decode([String].self, from: subscribedMachinesData) {
                self.subscribedMachineIDs = Set(decodedSubs)
            }
            self.fetchAlarms()
        }
    }
    
    @MainActor func containsAlarm(for machineID: String) -> Bool {
        if subscribedMachineIDs.contains(machineID) { return true }
        
        if !subscribedMachinesData.isEmpty, let decoded = try? JSONDecoder().decode([String].self, from: subscribedMachinesData) {
            if Set(decoded).contains(machineID) { return true }
        }
        
        guard let id = machineNotificationMapping[machineID] else { return false }
        return pendingRequestIDs.contains(id)
    }
    
    func subscribe(to machine: MachineDetail, and hallName: String) {
        let minutes = machine.timeRemaining
        let timeInterval = TimeInterval(minutes * 60)
        let content = UNMutableNotificationContent()
        let title = (machine.type == .washer) ? "Washer Ready" : "Dryer Ready"
        content.title = title
        content.body = hallName
        content.sound = .default
        
        Task { @MainActor in
            self.subscribedMachineIDs.insert(machine.id)
        }
        
        let identifier: String
        if let existing = machineNotificationMapping[machine.id] {
            identifier = existing
        } else {
            identifier = UUID().uuidString
            Task { @MainActor in
                self.machineNotificationMapping[machine.id] = identifier
            }
        }
        
        center.requestAuthorization(options: [.alert, .sound]) { [weak self] granted, _ in
            guard let self = self else { return }
            guard granted else { return }
            
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: max(1, timeInterval), repeats: false)
            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
            let center = UNUserNotificationCenter.current()
            center.add(request) { _ in }
            
            Task { @MainActor in
                self.pendingRequestIDs.insert(identifier)
            }
        }
        
        for activity in Activity<MachineData>.activities {
            if activity.attributes.machine.id == machine.id {
                Task {
                    await activity.end(nil, dismissalPolicy: .immediate)
                }
            }
        }
        let attributes = MachineData(hallName: hallName, machine: machine)
        let activity_content = ActivityContent(state: MachineData.ContentState(), staleDate: nil)
        _ = try? Activity<MachineData>.request(attributes: attributes, content: activity_content)
        
    }
    
    func unsubscribe(from machine: MachineDetail) {
        Task { @MainActor in
            self.subscribedMachineIDs.remove(machine.id)
        }
        if let identifier = machineNotificationMapping[machine.id] {
            center.removePendingNotificationRequests(withIdentifiers: [identifier])
            Task { @MainActor in
                self.pendingRequestIDs.remove(identifier)
                self.machineNotificationMapping[machine.id] = nil
            }
        }
        
        Activity<MachineData>.activities.forEach { activity in
            if activity.attributes.machine.id == machine.id {
                Task {
                    await activity.end(nil, dismissalPolicy: .immediate)
                }
            }
        }
    }
    
    func fetchAlarms() {
        center.getPendingNotificationRequests { [weak self] requests in
            guard let self = self else { return }
            let ids = Set(requests.map { $0.identifier })
            Task { @MainActor in
                self.pendingRequestIDs = ids
            }
        }
    }
}


