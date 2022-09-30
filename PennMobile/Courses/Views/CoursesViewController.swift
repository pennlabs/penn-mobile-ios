//
//  CoursesViewController.swift
//  PennMobile
//
//  Created by Anthony Li on 9/30/22.
//  Copyright © 2022 PennLabs. All rights reserved.
//

import SwiftUI

class CoursesViewController: GenericSwiftUIViewController<CoursesView> {
    override func makeSwiftUIView() -> CoursesView {
        CoursesView()
    }
    
    override var tabTitle: String? {
        "Course Schedule"
    }
}
