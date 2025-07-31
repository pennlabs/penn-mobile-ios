//
//  Untitled.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 11/25/24.
//  Copyright © 2024 PennLabs. All rights reserved.
//

import Foundation
import SwiftUI

public protocol WrappedStage: Identifiable, View {
    var id: UUID { get }
    var activeState: WrappedExperienceState { get }
    var onFinish: (Bool) -> Void { get set }
    func start() async
}
