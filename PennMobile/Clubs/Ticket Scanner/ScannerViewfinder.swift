//
//  ScannerViewfinder.swift
//  PennMobile
//
//  Created by Anthony Li on 4/22/24.
//  Copyright © 2024 PennLabs. All rights reserved.
//

import SwiftUI
import UIKit
import AVFoundation

struct ScannerViewfinder: UIViewRepresentable {
    @EnvironmentObject var viewModel: ScannerViewModel
        
    func makeUIView(context: Context) -> InternalView {
        let view = InternalView()
        view.videoPreviewLayer.videoGravity = .resizeAspectFill
        
        updateUIView(view, context: context)
        return view
    }
    
    func updateUIView(_ uiView: InternalView, context: Context) {
        uiView.videoPreviewLayer.session = viewModel.captureSession
        viewModel.previewLayer = uiView.videoPreviewLayer
    }
    
    class InternalView: UIView {
        override class var layerClass: AnyClass {
            AVCaptureVideoPreviewLayer.self
        }
        
        var videoPreviewLayer: AVCaptureVideoPreviewLayer {
            layer as! AVCaptureVideoPreviewLayer
        }
    }
}
