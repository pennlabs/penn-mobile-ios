//
//  ToastAttachmentExtension.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 9/25/26.
//  Copyright © 2026 PennLabs. All rights reserved.
//

import SwiftUI
import PennMobileShared

struct ToastOverlayView<Content: View>: View {
    let content: () -> Content
    @State var toast: ToastConfiguration?
    @State var toastOffset: Double = 0.0
    
    var body: some View {
        content()
            .overlay(alignment: .top) {
                if let toast {
                    ToastView(configuration: toast)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                        .padding(.top)
                        .offset(y: toastOffset)
                        .gesture (
                            DragGesture()
                                .onChanged { drag in
                                    // Do not allow the offset to be made positive (go further down the page)
                                    toastOffset = drag.translation.height < 0 ? drag.translation.height : 0
                                }
                                .onEnded { drag in
                                    // End behavior calculated based on where the gesture ends (top edge of screen).
                                    let shouldEnd = drag.location.y < 25
                                    if shouldEnd {
                                        withAnimation {
                                            self.toast = nil
                                        }
                                    } else {
                                        withAnimation(.snappy) {
                                            toastOffset = 0.0
                                        }
                                    }
                                }
                        )
                        .accessibilityElement(children: .combine)
                        .accessibilityAction {
                            self.toast = nil
                        }
                        .accessibilityHint("Dismisses the toast")
                }
            }
            .onAppear {
                ToastPresentationManager.shared.attachCallbackFunction { configuration in
                    toast?.postAccessibilityAnnouncement()
                    withAnimation {
                        toast = configuration
                    }
                }
            }
            .task(id: toast?.id) {
                if toast != nil {
                    try? await Task.sleep(for: .seconds(5))
                    if !Task.isCancelled {
                        withAnimation {
                            toast = nil
                        }
                    }
                }
            }
            .onChange(of: toast?.id) {
                toastOffset = 0.0
            }
    }
}

extension View {
    @ViewBuilder func attachToastPresentationManager() -> some View {
        ToastOverlayView {
            self
        }
    }
}
