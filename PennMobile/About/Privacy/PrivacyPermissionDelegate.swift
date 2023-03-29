//
//  PrivacyPermissionDelegate.swift
//  PennMobile
//
//  Created by Dominic Holmes on 12/31/19.
//  Copyright © 2019 PennLabs. All rights reserved.
//
#if canImport(SwiftUI)
import SwiftUI
#endif
#if canImport(Combine)
import Combine
#endif

class PrivacyPermissionDelegate: ObservableObject {
    var objectWillChange = PassthroughSubject<PrivacyPermissionDelegate, Never>()
    var objectDidChange = PassthroughSubject<PrivacyPermissionDelegate, Never>()

    var userDecision: PermissionView.Choice? {
        willSet {
            objectWillChange.send(self)
        }
        didSet {
            objectDidChange.send(self)
        }
    }
}
