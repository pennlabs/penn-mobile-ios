//
//  WidgetLiveActivity.swift
//  Widget
//
//  Created by Anthony Li on 10/16/22.
//  Copyright © 2022 PennLabs. All rights reserved.
//

import WidgetKit
import SwiftUI
import PennMobileShared
import ActivityKit

#if canImport(AlarmKit)
import AlarmKit
#endif

extension MachineDetail {
    var isWasher: Bool {
        self.type == .washer
    }
    var iconColor: Color {
        isWasher ? Color("baseBlue") : Color("baseRed")
    }
}

@available(iOS 16.1, *)
struct LaundryLiveActivityView: View {
    var attributes: MachineData
    
    var body: some View {
        HStack {
            Image(systemName: attributes.machine.isWasher ? "washer" : "dryer")
                .resizable()
                .scaledToFit()
                .frame(height: 60)
                .fontWeight(.light)
                .foregroundColor(attributes.machine.iconColor)
                .accessibilityLabel(attributes.machine.isWasher ? Text("Washing") : Text("Drying"))
            Spacer()
            VStack(alignment: .trailing) {
                Text(attributes.hallName)
                    .fontWeight(.medium)
                    .textCase(.uppercase)
                    .font(.subheadline)
                Text(timerInterval: Date.now...attributes.dateComplete, showsHours: false)
                    .font(.largeTitle)
                    .fontWeight(.bold)
            }
            .multilineTextAlignment(.trailing)
        }
    }
}

@available(iOS 16.1, *)
struct LaundryLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: MachineData.self) { context in
            LaundryLiveActivityView(attributes: context.attributes)
                .environment(\.colorScheme, .dark)
                .padding(24)
                .activityBackgroundTint(Color("liveActivityBackground"))
                .activitySystemActionForegroundColor(context.attributes.machine.iconColor)
        } dynamicIsland: { context in
            let isWasher = context.attributes.machine.isWasher
            let color = isWasher ? Color("baseBlue") : Color("baseRed")
            let dateComplete = context.attributes.dateComplete
            
            return DynamicIsland {
                DynamicIslandExpandedRegion(.bottom) {
                    LaundryLiveActivityView(attributes: context.attributes)
                }
            } compactLeading: {
                Image(systemName: isWasher ? "washer" : "dryer")
                    .foregroundColor(color)
            } compactTrailing: {
                Text(timerInterval: Date.now...dateComplete, showsHours: false)
                    .fontWeight(.medium)
                    .foregroundColor(color)
                    .frame(width: 42)
                    .multilineTextAlignment(.center)
            } minimal: {
                Text(timerInterval: Date.now...dateComplete, showsHours: false)
                    .foregroundColor(color)
                    .font(.caption2)
                    .minimumScaleFactor(0.1)
                    .frame(width: 36)
                    .multilineTextAlignment(.center)
            }
            .keylineTint(color)
        }
    }
}

@available(iOS 26.0, *)
struct AlarmKitLaundryLiveActivityView: View {
    var attributes: AlarmAttributes<MachineData>
    
    var body: some View {
        let metadata = attributes.metadata
        let isWasher = metadata?.machine.isWasher ?? true
        let color = isWasher ? Color("baseBlue") : Color("baseRed")
        let hallName = metadata?.hallName ?? "Laundry"
        let dateComplete = metadata?.dateComplete ?? Date().addingTimeInterval(60)
        
        return HStack {
            Image(systemName: isWasher ? "washer" : "dryer")
                .resizable()
                .scaledToFit()
                .frame(height: 60)
                .fontWeight(.light)
                .foregroundColor(color)
                .accessibilityLabel(isWasher ? Text("Washing") : Text("Drying"))
            Spacer()
            VStack(alignment: .trailing) {
                Text(hallName)
                    .fontWeight(.medium)
                    .textCase(.uppercase)
                    .font(.subheadline)
                Text(timerInterval: Date.now...dateComplete, showsHours: false)
                    .font(.largeTitle)
                    .fontWeight(.bold)
            }
            .multilineTextAlignment(.trailing)
        }
    }
}
@available(iOS 26.0, *)
struct LaundryAlarmKitLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: AlarmAttributes<MachineData>.self) { context in
            AlarmKitLaundryLiveActivityView(attributes: context.attributes)
                .environment(\.colorScheme, .dark)
                .padding(24)
                .activityBackgroundTint(Color("liveActivityBackground"))
                .activitySystemActionForegroundColor(context.attributes.metadata?.machine.iconColor ?? .accentColor)
        } dynamicIsland: { context in
            let isWasher = context.attributes.metadata?.machine.isWasher ?? true
            let color = isWasher ? Color("baseBlue") : Color("baseRed")
            let dateComplete = context.attributes.metadata?.dateComplete ?? Date().addingTimeInterval(60)
            
            return DynamicIsland {
                DynamicIslandExpandedRegion(.bottom) {
                    AlarmKitLaundryLiveActivityView(attributes: context.attributes)
                }
            } compactLeading: {
                Image(systemName: isWasher ? "washer" : "dryer")
                    .foregroundColor(color)
            } compactTrailing: {
                Text(timerInterval: Date.now...dateComplete, showsHours: false)
                    .fontWeight(.medium)
                    .foregroundColor(color)
                    .frame(width: 42)
                    .multilineTextAlignment(.center)
            } minimal: {
                Text(timerInterval: Date.now...dateComplete, showsHours: false)
                    .foregroundColor(color)
                    .font(.caption2)
                    .minimumScaleFactor(0.1)
                    .frame(width: 36)
                    .multilineTextAlignment(.center)
            }
            .keylineTint(color)
        }
    }
}

