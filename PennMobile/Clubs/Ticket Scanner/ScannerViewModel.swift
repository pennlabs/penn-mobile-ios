//
//  ScannerViewModel.swift
//  PennMobile
//
//  Created by Anthony Li on 4/22/24.
//  Copyright © 2024 PennLabs. All rights reserved.
//

import SwiftUI
import AVFoundation
import Vision
import Combine

enum CameraState {
    case settingUp
    case noCameraFound
    case ready
}

extension CVImageBuffer: @unchecked Sendable {}

actor ScannerSession: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    let session = AVCaptureSession()
    nonisolated let barcodes = PassthroughSubject<[VNBarcodeObservation], Never>()
    
    var output: AVCaptureVideoDataOutput?
    
    var isProcessingRequest = false
    
    let requestHandler = VNSequenceRequestHandler()
    
    func setup() -> CameraState {
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back), let input = try? AVCaptureDeviceInput(device: device), session.canAddInput(input) else {
            return .noCameraFound
        }
        
        let output = AVCaptureVideoDataOutput()
        output.setSampleBufferDelegate(self, queue: .global(qos: .userInitiated))
        
        session.beginConfiguration()
        session.addInput(input)
        session.addOutput(output)
        session.commitConfiguration()
        
        session.startRunning()
        
        self.output = output
        return .ready
    }
    
    func destroy() {
        session.stopRunning()
        output = nil
    }
    
    func process(observations: [VNObservation]) {
        barcodes.send(observations.compactMap { $0 as? VNBarcodeObservation })
    }
    
    func process(buffer: CVImageBuffer) {
        if isProcessingRequest {
            return
        }
        
        let request = VNDetectBarcodesRequest { [self] request, error in
            Task {
                isProcessingRequest = false
                
                if let error {
                    print("Error while detecting barcodes: \(error)")
                }
                
                if let results = request.results {
                    process(observations: results)
                }
            }
        }
        
        do {
            try requestHandler.perform([request], on: buffer)
            isProcessingRequest = false
        } catch {
            print("Unable to dispatch barcode detection request: \(error)")
        }
    }
    
    nonisolated func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        if let image = sampleBuffer.imageBuffer {
            Task {
                await process(buffer: image)
            }
        }
    }
}

@MainActor class ScannerViewModel: ObservableObject {
    let scannerSession = ScannerSession()
    var cancellables = Set<AnyCancellable>()
    
    var captureSession: AVCaptureSession {
        scannerSession.session
    }
    
    @Published var cameraState = CameraState.settingUp
    
    init() {
        scannerSession.barcodes.receive(on: DispatchQueue.main).sink { barcodes in
            if !barcodes.isEmpty {
                print(barcodes)
            }
        }.store(in: &cancellables)
    }
    
    func setup() {
        Task {
            cameraState = await scannerSession.setup()
        }
    }
    
    func destroy() {
        cameraState = .settingUp
        Task {
            await scannerSession.destroy()
        }
    }
}
