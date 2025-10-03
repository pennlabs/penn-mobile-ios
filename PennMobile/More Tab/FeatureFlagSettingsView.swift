//
//  FeatureFlagSettingsView.swift
//  PennMobile
//
//  Created by Anthony Li on 10/3/25.
//  Copyright © 2025 PennLabs. All rights reserved.
//

import PennMobileShared
import SwiftUI

struct FeatureFlagSettingsView: View {
    @State var channelOverride: RolloutChannel? = RolloutChannel(rawValue: UserDefaults.group.integer(forKey: RolloutChannel.overrideDefaultsKey)) {
        didSet {
            UserDefaults.group.set(channelOverride?.rawValue, forKey: RolloutChannel.overrideDefaultsKey)
        }
    }
    
    var currentChannel: RolloutChannel {
        channelOverride ?? RolloutChannel.inferred
    }
    
    @State var flagOverrides = Dictionary(uniqueKeysWithValues: FeatureFlags.shared.configurableFlags.compactMap { flag in
        if UserDefaults.group.object(forKey: flag.defaultsKey) != nil {
            return (flag.name, UserDefaults.group.bool(forKey: flag.defaultsKey))
        } else {
            return nil
        }
    })
    
    var body: some View {
        List {
            Section {
                HStack {
                    Image(systemName: "flag.filled.and.flag.crossed")
                        .imageScale(.large)
                        .foregroundStyle(.tint)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Feature Flags")
                            .font(.headline)
                            .bold()
                        
                        Text("Test out experimental features of Penn Mobile. **Experiments may result in crashes or other unexpected behavior.**")
                            .foregroundStyle(.secondary)
                        
                        Text("You must restart the app to apply these changes.")
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                }
                
                Picker("Channel", selection: $channelOverride) {
                    let inferred = RolloutChannel.inferred
                    Label {
                        Text("Auto — ") + Text(inferred.name)
                    } icon: {
                        inferred.icon
                    }
                    .tag(RolloutChannel?.none)
                    
                    ForEach(RolloutChannel.configurable, id: \.self) { channel in
                        Label {
                            Text(channel.name)
                        } icon: {
                            channel.icon
                        }
                        .tag(RolloutChannel?.some(channel))
                    }
                }
                
                Button("Exit App & Apply Changes") {
                    exit(0)
                }
            }
            
            ForEach(RolloutChannel.allCases, id: \.self) { channel in
                Section {
                    let flags = FeatureFlags.shared.configurableFlags.filter { $0.channel == channel }
                    ForEach(flags) { flag in
                        if case .environmentVariable(let isOn) = flag.state {
                            Picker(flag.name, selection: .constant(0)) {
                                if isOn {
                                    Label("Environment (On)", systemImage: "apple.terminal")
                                        .tag(0)
                                } else {
                                    Label("Environment (Off)", systemImage: "apple.terminal")
                                        .tag(0)
                                }
                            }
                            .disabled(true)
                        } else {
                            let binding = Binding<Bool?> {
                                flagOverrides[flag.name]
                            } set: { value in
                                flagOverrides[flag.name] = value
                                flag.setOverride(isSet: value)
                            }
                            
                            Picker(flag.name, selection: binding) {
                                if flag.channel <= currentChannel {
                                    Label("Default (On)", systemImage: "circle.badge.checkmark")
                                        .tag(Bool?.none)
                                } else {
                                    Label("Default (Off)", systemImage: "circle.badge.xmark")
                                        .tag(Bool?.none)
                                }
                                
                                Label("Off", systemImage: "xmark")
                                    .tag(Bool?.some(false))
                                
                                Label("On", systemImage: "checkmark")
                                    .tag(Bool?.some(true))
                            }
                        }
                    }
                } header: {
                    Label {
                        Text(channel.name)
                    } icon: {
                        channel.icon
                    }
                }
                .tint(channel.color)
            }
        }
        .navigationTitle("Feature Flags")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        FeatureFlagSettingsView()
    }
}
