//
//  DiningAnalyticsProvider.swift
//  PennMobile
//
//  Created by Anthony Li on 11/5/22.
//  Copyright © 2022 PennLabs. All rights reserved.
//

import WidgetKit
import Intents

struct DiningAnalyticsEntry<Configuration>: TimelineEntry {
    let date: Date
    let configuration: Configuration
}
