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
    func subscribe(to machine: MachineDetail, and hallName: String) async throws
    func unsubscribe(from machine: MachineDetail) async throws
    func fetchAlarms()
    func containsAlarm(for machineID: String) -> Bool
    func requestAuthorization() async throws -> Bool
}

enum LaundryAlarmService {
    @MainActor static func makeHandler() -> LaundryAlarmHandler {
        if #available(iOS 26.0, *) {
            if ProcessInfo.processInfo.isiOSAppOnMac {
                return FallbackAlarmHandler()
            }
            
            if #available(iOS 26.1, *), ProcessInfo.processInfo.isiOSAppOnVision {
                // you're welcome anthony
                return FallbackAlarmHandler()
            }
            
            return AlarmKitAlarmHandler()
        }
        
        return FallbackAlarmHandler()
    }
}

enum LaundryAlarmError : Swift.Error, LocalizedError {
    case authorizationDenied
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
@MainActor
@Observable final class AlarmKitAlarmHandler: LaundryAlarmHandler {
    
    typealias AlarmConfiguration = AlarmManager.AlarmConfiguration<MachineData>
    typealias AlarmsMap = [UUID: (Alarm, LocalizedStringResource)]
    
    var alarmsMap = AlarmsMap()
    @ObservationIgnored private let alarmManager = AlarmManager.shared
    
    @ObservationIgnored
    @AppStorage("machineAlarmMapping")
    private var data: Data = Data()
    
    var machineAlarmMapping: [String: UUID] = [:] {
        didSet {
            if let encoded = try? JSONEncoder().encode(machineAlarmMapping) {
                data = encoded
            }
        }
    }
    
    var hasUpcomingAlerts: Bool {
        !alarmsMap.isEmpty
    }
    
    init() {
        if let decoded = try? JSONDecoder().decode([String: UUID].self, from: data) {
            self.machineAlarmMapping = decoded
        }
        
        self.fetchAlarms()
        observeAlarms()
    }
    
    func containsAlarm(for machineID: String) -> Bool {
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
    
    func requestAuthorization() async throws -> Bool {
        switch alarmManager.authorizationState {
        case .notDetermined:
            let state = try await alarmManager.requestAuthorization()
            return state == .authorized
        case .denied: return false
        case .authorized: return true
        @unknown default: return false
        }
    }
    
    func subscribe(to machine: MachineDetail, and hallName: String) async throws {
        let alertContent = AlarmPresentation.Alert(title: LocalizedStringResource("\(machine.type.label) Ready"),
                                                   stopButton: .stopButton,
                                                   secondaryButton: nil,
                                                   secondaryButtonBehavior: nil)
        
        let countdownContent = AlarmPresentation.Countdown(title: machine.type.label)
        
        let alarmPresentation = AlarmPresentation(alert: alertContent, countdown: countdownContent, paused: nil)
        
        let time = TimeInterval(machine.timeRemaining * 60)
        
        let dateComplete = Date().addingTimeInterval(time)
        
        let attributes = AlarmAttributes<MachineData>(presentation: alarmPresentation, metadata: MachineData(hallName: hallName, machine: machine, dateComplete: dateComplete), tintColor: Color.accentColor)
        
        let id = machineAlarmMapping[machine.id] ?? UUID()
        
        machineAlarmMapping[machine.id] = id
        
        
        let alarmConfiguration = AlarmConfiguration(countdownDuration: .init(preAlert: time, postAlert: time), attributes: attributes)
        
        try await scheduleAlarm(id: id, label: LocalizedStringResource(stringLiteral: hallName), alarmConfiguration: alarmConfiguration)
    }
    
    private func scheduleAlarm(id: UUID, label: LocalizedStringResource, alarmConfiguration: AlarmConfiguration) async throws {
        guard try await requestAuthorization() else {
            throw LaundryAlarmError.authorizationDenied
        }
        let alarm = try await alarmManager.schedule(id: id, configuration: alarmConfiguration)
        
        alarmsMap[id] = (alarm, label)
    }
    
    func fetchAlarms() {
        do {
            let remoteAlarms = try alarmManager.alarms
            updateAlarmState(with: remoteAlarms)
        } catch {
            print("Error fetching alarms: \(error)")
        }
    }
    
    func unsubscribe(from machine: MachineDetail) async throws {
        if let id = machineAlarmMapping[machine.id] {
            try alarmManager.cancel(id: id)
            alarmsMap[id] = nil
            
            machineAlarmMapping[machine.id] = nil
        }
    }
}

@MainActor
@Observable final class FallbackAlarmHandler: LaundryAlarmHandler {
    
    private static let userDefaultsKey = "fallbackMachineAlarmMapping"
    
    var machineAlarmMapping: [String: UUID] = [:] {
        didSet {
            Self.saveMappingToDefaults(machineAlarmMapping)
        }
    }
    
    init() {
        self.machineAlarmMapping = Self.loadMappingFromDefaults()
        fetchAlarms()
    }
    
    private static func loadMappingFromDefaults() -> [String: UUID] {
        guard let data = UserDefaults.standard.data(forKey: userDefaultsKey),
              let decoded = try? JSONDecoder().decode([String: UUID].self, from: data) else {
            return [:]
        }
        return decoded
    }
    
    private static func saveMappingToDefaults(_ mapping: [String: UUID]) {
        if let encoded = try? JSONEncoder().encode(mapping) {
            UserDefaults.standard.set(encoded, forKey: userDefaultsKey)
        }
    }
    
    
    func containsAlarm(for machineID: String) -> Bool {
        machineAlarmMapping[machineID] != nil
    }
    
    func subscribe(to machine: MachineDetail, and hallName: String) async throws {
        guard try await requestAuthorization() else {
            throw LaundryAlarmError.authorizationDenied
        }
        
        let id = machineAlarmMapping[machine.id] ?? UUID()
        machineAlarmMapping[machine.id] = id
        
        let content = UNMutableNotificationContent()
        let typeLabel = machine.type == .washer ? "Washer" : "Dryer"
        content.title = "\(typeLabel) Ready"
        content.body = "Your \(typeLabel.lowercased()) at \(hallName) has finished its cycle."
        content.sound = .default
        
        let timeInterval = TimeInterval(machine.timeRemaining * 60)
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: max(timeInterval, 1), repeats: false)
        let request = UNNotificationRequest(identifier: id.uuidString, content: content, trigger: trigger)
        
        do {
            try await UNUserNotificationCenter.current().add(request)
        } catch {
            print("Error scheduling notification: \(error)")
            machineAlarmMapping[machine.id] = nil
            throw error
        }
        
        startLiveActivity(for: machine, hallName: hallName)
    }
    
    func unsubscribe(from machine: MachineDetail) throws {
        if let id = machineAlarmMapping[machine.id] {
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id.uuidString])
            machineAlarmMapping[machine.id] = nil
        }
        
        Task { await endLiveActivity(for: machine) }
    }
    
    func fetchAlarms() {
        Task {
            let center = UNUserNotificationCenter.current()
            let pendingRequests = await center.pendingNotificationRequests()
            let pendingIdentifiers = Set(pendingRequests.map(\.identifier))
            
            for (machineID, alarmID) in machineAlarmMapping {
                if !pendingIdentifiers.contains(alarmID.uuidString) {
                    machineAlarmMapping[machineID] = nil
                }
            }
            
            await pruneStaleActivities()
        }
    }
    
    func requestAuthorization() async throws -> Bool {
        let center = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()
        switch settings.authorizationStatus {
        case .notDetermined:
            return try await center.requestAuthorization(options: [.alert, .sound, .badge])
        case .authorized, .provisional, .ephemeral:
            return true
        case .denied:
            return false
        @unknown default:
            return false
        }
    }
    
    
    private func startLiveActivity(for machine: MachineDetail, hallName: String) {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            print("Live Activities are not enabled.")
            return
        }
        
        let dateComplete = Date().addingTimeInterval(TimeInterval(machine.timeRemaining * 60))
        
        let attributes = MachineData(hallName: hallName, machine: machine, dateComplete: dateComplete)
        let initialState = MachineData.ContentState()
        let content = ActivityContent(state: initialState, staleDate: nil)
        
        do {
            _ = try Activity<MachineData>.request(
                attributes: attributes,
                content: content,
                pushType: nil
            )
        } catch {
            print("Error starting Live Activity: \(error)")
        }
    }
    
    private func endLiveActivity(for machine: MachineDetail) async {
        let finalState = MachineData.ContentState()
        let finalContent = ActivityContent(state: finalState, staleDate: nil)
        
        for activity in Activity<MachineData>.activities {
            if activity.attributes.machine.id == machine.id {
                await activity.end(finalContent, dismissalPolicy: .immediate)
            }
        }
    }
    
    private func pruneStaleActivities() async {
        let trackedMachineIDs = Set(machineAlarmMapping.keys)
        let finalState = MachineData.ContentState()
        let finalContent = ActivityContent(state: finalState, staleDate: nil)
        
        for activity in Activity<MachineData>.activities {
            if !trackedMachineIDs.contains(activity.attributes.machine.id) {
                await activity.end(finalContent, dismissalPolicy: .immediate)
            }
        }
    }
}
