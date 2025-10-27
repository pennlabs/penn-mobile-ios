//
//  FeatureFlags.swift
//  PennMobile
//
//  Created by Anthony Li on 9/12/25.
//  Copyright © 2025 PennLabs. All rights reserved.
//

import SwiftUI

public class FeatureFlags {
    private init() {}
    public static let shared = FeatureFlags()
    @MainActor public internal(set) var configurableFlags = [FeatureFlagDefinition]()
    
    @FeatureFlagDefinition("ALWAYS_SHOW_FEATURE_FLAG_SETTINGS", channel: .testFlight) public var alwaysShowFeatureFlagSettings
    @FeatureFlagDefinition("TEST_FEATURE_FLAG", channel: .adHoc) public var testFeatureFlag
    
    @FeatureFlagDefinition("GSR_AVAILABILITY_LABELS", channel: .testFlight) public var gsrAvailabilityLabels
    @FeatureFlagDefinition("GSR_QUICK_BOOK", channel: .testFlight) public var gsrQuickBook
    
    @MainActor public var showFeatureFlagSettings: Bool {
        if RolloutChannel.current >= .testFlight || alwaysShowFeatureFlagSettings || RolloutChannel.override != nil {
            return true
        } else {
            return configurableFlags.contains(where: {
                if $0.name != $alwaysShowFeatureFlagSettings.name, case .overriden = $0.state {
                    return true
                }
                
                return false
            })
        }
    }
}

public enum RolloutChannel: Int, Comparable, CaseIterable, Hashable {
    case appStore = 1
    case testFlight = 2
    case experimental = 3
    case adHoc = 4
    
    public static let configurable: [RolloutChannel] = [.appStore, .testFlight, .experimental]
    
    public var name: LocalizedStringKey {
        switch self {
        case .adHoc:
            "Ad-Hoc"
        case .experimental:
            "Experimental"
        case .testFlight:
            "TestFlight"
        case .appStore:
            "General Release"
        }
    }
    
    public var icon: Image {
        switch self {
        case .adHoc:
            Image(systemName: "exclamationmark.triangle.fill")
        case .experimental:
            Image(systemName: "testtube.2")
        case .testFlight:
            Image(systemName: "gear.badge")
        case .appStore:
            Image(systemName: "checkmark.seal.fill")
        }
    }
    
    public var color: Color {
        switch self {
        case .adHoc:
            Color.red
        case .experimental:
            Color.orange
        case .testFlight:
            Color.yellow
        case .appStore:
            Color.green
        }
    }
    
    public static func <(_ lhs: RolloutChannel, _ rhs: RolloutChannel) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
    
    public static let inferred: RolloutChannel = if let identifier = Bundle.main.bundleIdentifier, identifier.contains(/^org\.pennlabs\.PennMobile\.dev(\.|$)/) {
        .experimental
    } else if Bundle.main.appStoreReceiptURL?.lastPathComponent == "sandboxReceipt" {
        // TODO: Find a long-term replacement for the above check
        .testFlight
    } else {
        .appStore
    }
    
    public static var overrideDefaultsKey = "featureFlagChannelOverride"
    
    static let override = RolloutChannel(rawValue: UserDefaults.group.integer(forKey: overrideDefaultsKey))
    
    public static let current = override ?? inferred
}

public enum FeatureFlagState {
    case environmentVariable(Bool)
    case overriden(Bool)
    case `default`
    
    func isOn(flagChannel: RolloutChannel) -> Bool {
        switch self {
        case .environmentVariable(let value), .overriden(let value):
            return value
        case .default:
            return flagChannel <= RolloutChannel.current
        }
    }
}

private func featureFlagDefaultsKey(name: String) -> String {
    "featureFlag.\(name)"
}

private func determineInitialFeatureFlagState(name: String, channel: RolloutChannel) -> FeatureFlagState {
    switch ProcessInfo.processInfo.environment["FEATURE_FLAG_\(name)"]?.lowercased() {
    case "true":
        return .environmentVariable(true)
    case "false":
        return .environmentVariable(false)
    default:
        break
    }
    
    let defaultsKey = featureFlagDefaultsKey(name: name)
    if UserDefaults.group.object(forKey: defaultsKey) != nil {
        return .overriden(UserDefaults.group.bool(forKey: defaultsKey))
    }
    
    return .default
}

@propertyWrapper
public class FeatureFlagDefinition: Identifiable, Hashable {
    public let name: String
    public let channel: RolloutChannel
    public let state: FeatureFlagState
    public let isOn: Bool
    
    public var id: String {
        name
    }
    
    public static func ==(_ lhs: FeatureFlagDefinition, _ rhs: FeatureFlagDefinition) -> Bool {
        lhs === rhs
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
    
    fileprivate init(_ name: String, channel: RolloutChannel) {
        self.name = name
        self.channel = channel
        
        let state = determineInitialFeatureFlagState(name: name, channel: channel)
        
        self.state = state
        self.isOn = state.isOn(flagChannel: channel)
        
        Task { @MainActor in
            FeatureFlags.shared.configurableFlags.append(self)
        }
    }
    
    public var projectedValue: FeatureFlagDefinition {
        self
    }
    
    public var wrappedValue: Bool {
        isOn
    }
    
    public var defaultsKey: String {
        featureFlagDefaultsKey(name: name)
    }
    
    public func setOverride(isSet: Bool?) {
        if let isSet {
            UserDefaults.group.setValue(isSet, forKey: defaultsKey)
        } else {
            UserDefaults.group.removeObject(forKey: defaultsKey)
        }
    }
}
