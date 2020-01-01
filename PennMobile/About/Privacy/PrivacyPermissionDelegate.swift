//
//  PrivacyPermissionDelegate.swift
//  PennMobile
//
//  Created by Dominic Holmes on 12/31/19.
//  Copyright © 2019 PennLabs. All rights reserved.
//
import SwiftUI
import Combine

@available(iOS 13, *)
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
