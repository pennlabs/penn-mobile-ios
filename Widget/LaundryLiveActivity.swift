//
//  WidgetLiveActivity.swift
//  Widget
//
//  Created by Anthony Li on 10/16/22.
//  Copyright © 2022 PennLabs. All rights reserved.
//

//import WidgetKit
//import SwiftUI
//import PennMobileShared
//#if canImport(ActivityKit)
//import ActivityKit
//#endif
//
//extension LaundryMachine {
//    var iconColor: Color {
//        isWasher ? Color("baseBlue") : Color("baseRed")
//    }
//}
//
//struct LaundryLiveActivityView: View {
//    var attributes: LaundryAttributes
//
//    var body: some View {
//        HStack {
//            Image(systemName: attributes.machine.isWasher ? "washer" : "dryer").resizable().scaledToFit().frame(height: 60).fontWeight(.light).foregroundColor(attributes.machine.iconColor)
//                .accessibilityLabel(attributes.machine.isWasher ? Text("Washing") : Text("Drying"))
//            Spacer()
//            VStack(alignment: .trailing) {
//                Text(attributes.machine.roomName).fontWeight(.medium).textCase(.uppercase).font(.subheadline)
//                Text(timerInterval: Date.now...attributes.dateComplete, showsHours: false).font(.largeTitle).fontWeight(.bold)
//            }
//            .multilineTextAlignment(.trailing)
//        }
//    }
//}
//
//struct LaundryLiveActivityView_Previews: PreviewProvider {
//    static var previews: some View {
//        LaundryLiveActivityView(
//            attributes: LaundryAttributes(
//                machine: LaundryMachine(
//                    id: 1,
//                    isWasher: true,
//                    roomName: "Test Laundry Room",
//                    status: .running,
//                    timeRemaining: 45),
//                dateComplete: Date(timeIntervalSinceNow: 45 * 60)
//            )
//        )
//        .padding(24)
//        .previewContext(WidgetPreviewContext(family: .systemMedium))
//        LaundryLiveActivityView(
//            attributes: LaundryAttributes(
//                machine: LaundryMachine(
//                    id: 2,
//                    isWasher: false,
//                    roomName: "Test Laundry Room",
//                    status: .running,
//                    timeRemaining: 0),
//                dateComplete: Date(timeIntervalSinceNow: 0 * 60)
//            )
//        )
//        .padding(24)
//        .previewContext(WidgetPreviewContext(family: .systemMedium))
//    }
//}
//
//@available(iOS 16.1, *)
//struct LaundryLiveActivity: Widget {
//    var body: some WidgetConfiguration {
//        return ActivityConfiguration(for: LaundryAttributes.self) { context in
//            LaundryLiveActivityView(attributes: context.attributes)
//                .environment(\.colorScheme, .dark)
//                .padding(24)
//                .activityBackgroundTint(Color("liveActivityBackground"))
//                .activitySystemActionForegroundColor(context.attributes.machine.iconColor)
//        } dynamicIsland: { context in
//            let color = context.attributes.machine.isWasher ? Color("baseBlue") : Color("baseRed")
//
//            return DynamicIsland {
//                DynamicIslandExpandedRegion(.bottom) {
//                    LaundryLiveActivityView(attributes: context.attributes)
//                }
//            } compactLeading: {
//                Image(systemName: context.attributes.machine.isWasher ? "washer" : "dryer").foregroundColor(color)
//            } compactTrailing: {
//                Text(timerInterval: Date.now...context.attributes.dateComplete, showsHours: false).fontWeight(.medium).foregroundColor(color).frame(width: 42).multilineTextAlignment(.center)
//            } minimal: {
//                Text(timerInterval: Date.now...context.attributes.dateComplete, showsHours: false).foregroundColor(color).font(.caption2).minimumScaleFactor(0.1).frame(width: 36).multilineTextAlignment(.center)
//            }
//            .keylineTint(color)
//        }
//    }
//}

import WidgetKit
import SwiftUI
import PennMobileShared
#if canImport(ActivityKit)
import ActivityKit
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

extension MachineData {
    var dateComplete: Date {
        Date().addingTimeInterval(TimeInterval(machine.timeRemaining * 60))
    }
}

@available(iOS 26.0, *)
struct LaundryLiveActivityView: View {
    var attributes: AlarmAttributes<MachineData>
    
    var body: some View {
        if let metadata = attributes.metadata {
            HStack {
                Image(systemName: metadata.machine.isWasher ? "washer" : "dryer").resizable().scaledToFit().frame(height: 60).fontWeight(.light).foregroundColor(metadata.machine.iconColor)
                    .accessibilityLabel(metadata.machine.isWasher ? Text("Washing") : Text("Drying"))
                Spacer()
                VStack(alignment: .trailing) {
                    Text(metadata.hallName).fontWeight(.medium).textCase(.uppercase).font(.subheadline)
                    Text(timerInterval: Date.now...metadata.dateComplete, showsHours: false).font(.largeTitle).fontWeight(.bold)
                }
                .multilineTextAlignment(.trailing)
            }
        }
    }
}

@available(iOS 26.0, *)
struct LaundryLiveActivity: Widget {
    var body: some WidgetConfiguration {
        return ActivityConfiguration(for: AlarmAttributes<MachineData>.self) { context in
            if let metadata = context.attributes.metadata {
                LaundryLiveActivityView(attributes: context.attributes)
                    .environment(\.colorScheme, .dark)
                    .padding(24)
                    .activityBackgroundTint(Color("liveActivityBackground"))
                    .activitySystemActionForegroundColor(metadata.machine.iconColor)
            }
        } dynamicIsland: { context in
            let metadata = context.attributes.metadata
            let isWasher = metadata?.machine.isWasher ?? true
            let color = isWasher ? Color("baseBlue") : Color("baseRed")
            let dateComplete = metadata?.dateComplete ?? Date().addingTimeInterval(60)
            
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
