//
//  ToastPresentationManager.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 9/25/26.
//  Copyright © 2026 PennLabs. All rights reserved.
//

// need to mark entire class as mainactor to avoid mutable state race conditions
@MainActor
public final class ToastPresentationManager {
    public static let shared = ToastPresentationManager()
    private(set) var displayToast: ToastPresentationExecutor?
    public func attachCallbackFunction(displayToast: @escaping ToastPresentationExecutor) {
        self.displayToast = displayToast
    }
}
