//
//  WidgetBundle.swift
//  Widget
//
//  Created by Anthony Li on 10/16/22.
//  Copyright © 2022 PennLabs. All rights reserved.
//

import WidgetKit
import SwiftUI

struct EmptyWidget: Widget {
    var body: some WidgetConfiguration {
        EmptyWidgetConfiguration()
    }
}

@main
struct LabsWidgetBundle: WidgetBundle {
    var body: some Widget {
        EmptyWidget()
    }
}
