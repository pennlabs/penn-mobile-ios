//
//  LaundryAlarmService.swift
//  PennMobile
//
//  Created by Nathan Aronson on 11/21/25.
//  Copyright © 2025 PennLabs. All rights reserved.
//

import AlarmKit
import SwiftUI
import PennMobileShared

protocol LaundryAlarmHandler {
    func subscribe(to machine: MachineDetail, and hallName: String)
    func unsubscribe(from machine: MachineDetail)
    func fetchAlarms()
}

enum LaundryAlarmService {
    static func makeHandler() -> LaundryAlarmHandler {
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
        case .washer: LocalizedStringResource("Washing")
        case .dryer: LocalizedStringResource("Drying")
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
    private var machineAlarmMappingData: Data = Data()
    
    @MainActor private var machineAlarmMapping: [String: UUID] {
        get {
            guard let decoded = try? JSONDecoder().decode([String: UUID].self, from: machineAlarmMappingData) else {
                return [:]
            }
            return decoded
        }
        set {
            guard let encoded = try? JSONEncoder().encode(newValue) else { return }
            machineAlarmMappingData = encoded
        }
    }
    
    @MainActor var hasUpcomingAlerts: Bool {
        !alarmsMap.isEmpty
    }
    
    init() {
        observeAlarms()
    }
    
    @MainActor func containsAlarm(for machineID: String) -> Bool {
        machineAlarmMapping[machineID] != nil
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
            
            // Update existing alarm states.
            remoteAlarms.forEach { updated in
                alarmsMap[updated.id, default: (updated, "Alarm (Old Session)")].0 = updated
            }
            
            let knownAlarmIDs = Set(alarmsMap.keys)
            let incomingAlarmIDs = Set(remoteAlarms.map(\.id))
            
            // Clean-up removed alarms.
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
    func subscribe(to machine: MachineDetail, and hallName: String) {
        
    }
    
    func unsubscribe(from machine: MachineDetail) {
        
    }
    
    func fetchAlarms() {}
}
