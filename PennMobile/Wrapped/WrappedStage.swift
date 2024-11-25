//
//  Untitled.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 11/25/24.
//  Copyright © 2024 PennLabs. All rights reserved.
//

import Foundation
import SwiftUI

public protocol WrappedStage: Identifiable, View, AccessibilityRotorContent {
    var id: UUID { get }
    var onFinish: ((Result<Any?, Error>) -> Void) { get set }
    func start() async
    var activeState: WrappedExperienceState { get }
    var body: any View { get }
}
