//
//  CoursesViewController.swift
//  PennMobile
//
//  Created by Anthony Li on 9/30/22.
//  Copyright © 2022 PennLabs. All rights reserved.
//

import SwiftUI

/// Simple wrapper around ``CoursesView``.
class CoursesViewController: GenericSwiftUIViewController<AnyView> {
    override var content: AnyView {
        AnyView(CoursesView().environmentObject(CoursesViewModel.shared))
    }

    override var tabTitle: String? {
        "Course Schedule"
    }
}
