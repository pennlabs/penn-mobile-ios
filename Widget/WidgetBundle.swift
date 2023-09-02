//
//  WidgetBundle.swift
//  Widget
//
//  Created by Anthony Li on 10/16/22.
//  Copyright © 2022 PennLabs. All rights reserved.
//

import WidgetKit
import SwiftUI

@main
struct LabsWidgetBundle: WidgetBundle {
    var body: some Widget {
        DiningAnalyticsHomeWidget()
        CoursesDayWidget()
        if #available(iOS 16.1, *) {
            LaundryLiveActivity()
        }
    }
}
