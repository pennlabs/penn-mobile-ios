//
//  FeatureFlags.swift
//  PennMobile
//
//  Created by Anthony Li on 9/12/25.
//  Copyright © 2025 PennLabs. All rights reserved.
//

public enum FeatureFlags {
    @MainActor public internal(set) static var configurableFlags = [FeatureFlagDefinition]()
    
    @FeatureFlagDefinition("TEST_FEATURE_FLAG", channel: .experimental) public static var testFeatureFlag
}

public enum RolloutChannel {
    case appStore
    case testFlight
    case experimental
    case adHoc
}

public enum FeatureFlagState {
    case environmentVariable(Bool)
    case overriden(Bool)
    case `default`
    
    private static let isDevVersion = Bundle.main.bundleIdentifier?.contains(/^org\.pennlabs\.PennMobile\.dev(\.|$)/) ?? false
    
    // TODO: Find a long-term replacement for this
    private static let isTestFlight = Bundle.main.appStoreReceiptURL?.lastPathComponent == "sandboxReceipt"
    
    func isOn(channel: RolloutChannel) -> Bool {
        switch self {
        case .environmentVariable(let value), .overriden(let value):
            return value
        case .default:
            switch channel {
            case .appStore:
                return true
            case .testFlight:
                return Self.isDevVersion || Self.isTestFlight
            case .experimental:
                return Self.isDevVersion
            case .adHoc:
                return false
            }
        }
    }
}

private func featureFlagDefaultsKey(name: String) -> String {
    "featureFlag.\(name)"
}

private func determineInitialFeatureFlagState(name: String, channel: RolloutChannel) -> FeatureFlagState {
    switch ProcessInfo.processInfo.environment["FEATURE_FLAG_\(name)"]?.lowercased() {
    case "true":
        return .overriden(true)
    case "false":
        return .overriden(false)
    default:
        break
    }
    
    let defaultsKey = featureFlagDefaultsKey(name: name)
    if UserDefaults.group.object(forKey: defaultsKey) != nil {
        return .overriden(UserDefaults.group.bool(forKey: name))
    }
    
    return .default
}

@propertyWrapper
public class FeatureFlagDefinition {
    public let name: String
    public let channel: RolloutChannel
    public let state: FeatureFlagState
    public let isOn: Bool
    
    fileprivate init(_ name: String, channel: RolloutChannel) {
        self.name = name
        self.channel = channel
        
        let state = determineInitialFeatureFlagState(name: name, channel: channel)
        
        self.state = state
        self.isOn = state.isOn(channel: channel)
        
        Task { @MainActor in
            FeatureFlags.configurableFlags.append(self)
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
