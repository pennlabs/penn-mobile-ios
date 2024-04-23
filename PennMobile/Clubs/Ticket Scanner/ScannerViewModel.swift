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
import CoreHaptics

enum CameraState {
    case settingUp
    case noCameraFound
    case ready
}

extension CVImageBuffer: @unchecked Sendable {}

extension CHHapticEngine {
    func makePlayer(hapticName: String) throws -> CHHapticPatternPlayer {
        guard let url = Bundle.main.url(forResource: hapticName, withExtension: "ahap") else {
            throw NSError(domain: NSCocoaErrorDomain, code: NSFileNoSuchFileError)
        }
        
        return try makePlayer(with: .init(contentsOf: url))
    }
}

actor ScannerSession: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    let session = AVCaptureSession()
    nonisolated let results = PassthroughSubject<[VNBarcodeObservation], Never>()
    
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
    
    func process(observations: [VNObservation], size: CGSize) {
        results.send(observations.compactMap { $0 as? VNBarcodeObservation })
    }
    
    func process(buffer: CVImageBuffer) {
        if isProcessingRequest {
            return
        }
        
        let request = VNDetectBarcodesRequest { [self] request, error in
            isProcessingRequest = false
            
            if let error {
                print("Error while detecting barcodes: \(error)")
            }
            
            if let results = request.results {
                
                process(observations: results, size: CVImageBufferGetEncodedSize(buffer))
            }
        }
        
        request.symbologies = [.qr]
        
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

struct ScannerBarcode {
    enum Status {
        case active
        case pending
        case alreadyScanned
    }
    
    var status: Status
    var observation: VNBarcodeObservation
}

@MainActor class ScannerViewModel: ObservableObject {
    static let scanThrottle: TimeInterval = 1
    
    private let scannerSession = ScannerSession()
    private var cancellables = Set<AnyCancellable>()
    
    private var hapticEngine: CHHapticEngine?
    private var validHapticPlayer: CHHapticPatternPlayer?
    private var duplicateHapticPlayer: CHHapticPatternPlayer?
    private var invalidHapticPlayer: CHHapticPatternPlayer?
    private var errorHapticPlayer: CHHapticPatternPlayer?
    
    var captureSession: AVCaptureSession {
        scannerSession.session
    }
    
    weak var previewLayer: AVCaptureVideoPreviewLayer?
    private var seenVisibleBarcodes = Set<String>()
    private var scanTimes = [String: Date]()
    
    @Published var cameraState = CameraState.settingUp
    @Published var scannerState = ScannerState.noTicket {
        didSet {
            switch scannerState {
            case .error:
                playHaptic(player: errorHapticPlayer)
            case .scanned(let ticket, _):
                switch ticket.status {
                case .valid:
                    playHaptic(player: validHapticPlayer)
                case .duplicate:
                    playHaptic(player: duplicateHapticPlayer)
                case .invalid:
                    playHaptic(player: invalidHapticPlayer)
                }
            default:
                break
            }
        }
    }
    
    @Published var barcodes = [ScannerBarcode]()
    
    private var isReadyForNextScan: Bool {
        switch scannerState {
        case .noTicket:
            return true
        case .scanned(let ticket, _):
            return ticket.scanTime.timeIntervalSinceNow < -Self.scanThrottle
        default:
            return false
        }
    }
    
    init() {
        scannerSession.results.receive(on: DispatchQueue.main).sink { [self] results in
            process(barcodes: results)
        }.store(in: &cancellables)
        
        hapticEngine = try? CHHapticEngine()
        
        if let hapticEngine {
            validHapticPlayer = try? hapticEngine.makePlayer(hapticName: "ScannerValid")
            duplicateHapticPlayer = try? hapticEngine.makePlayer(hapticName: "ScannerDuplicate")
            invalidHapticPlayer = try? hapticEngine.makePlayer(hapticName: "ScannerInvalid")
            errorHapticPlayer = try? hapticEngine.makePlayer(hapticName: "ScannerError")
        }
    }
    
    func setup() {
        try? hapticEngine?.start()
        
        Task {
            cameraState = await scannerSession.setup()
        }
    }
    
    private func process(barcodes: [VNBarcodeObservation]) {
        let filteredBarcodes = barcodes.lazy.filter { $0.payloadStringValue != nil }
        seenVisibleBarcodes.formIntersection(filteredBarcodes.map { $0.payloadStringValue! })
        
        // Split barcodes into active and candidate ones
        var activeBarcodes = Set<VNBarcodeObservation>()
        var inactiveBarcodes = Set<VNBarcodeObservation>()
        var alreadyScannedBarcodes = Set<VNBarcodeObservation>()
        
        var currentString = switch scannerState {
                            case .loading(let str), .scanned(_, let str):
                                str
                            default:
                                String?.none
        }
        
        for barcode in filteredBarcodes {
            if barcode.payloadStringValue! == currentString {
                activeBarcodes.insert(barcode)
            } else if seenVisibleBarcodes.contains(barcode.payloadStringValue!) {
                alreadyScannedBarcodes.insert(barcode)
            } else {
                inactiveBarcodes.insert(barcode)
            }
        }
        
        // If we're ready for another barcode, promote one of the inactive barcodes
        if isReadyForNextScan, let barcode = inactiveBarcodes.min(by: { a, b in
            let aScanTime = scanTimes[a.payloadStringValue!, default: .distantPast]
            let bScanTime = scanTimes[b.payloadStringValue!, default: .distantPast]
            if aScanTime != bScanTime {
                return aScanTime < bScanTime
            }
            
            // TODO: Sort barcodes by size
            return false
        }) {
            inactiveBarcodes.remove(barcode)
            activeBarcodes.insert(barcode)
            
            Task {
                await check(ticketString: barcode.payloadStringValue!)
            }
        }
        
        // Expose the barcodes to the ScannerView
        self.barcodes = activeBarcodes.map {
            ScannerBarcode(status: .active, observation: $0)
        } + inactiveBarcodes.map {
            ScannerBarcode(status: .pending, observation: $0)
        } + alreadyScannedBarcodes.map {
            ScannerBarcode(status: .alreadyScanned, observation: $0)
        }
    }
    
    private var i = 0
    private func check(ticketString: String) async {
        scannerState = .loading(ticketString)
        scanTimes[ticketString] = Date()
        
        // Prevent previously seen barcodes from being rescanned until they leave frame
        seenVisibleBarcodes.insert(ticketString)
        
        try? await Task.sleep(for: .seconds(0.2))
        scannerState = .scanned(ScannedTicket(status: .allCases[i % 3], scanTime: Date()), ticketString)
        i += 1
    }
    
    func destroy() {
        cameraState = .settingUp
        scannerState = .noTicket
        barcodes = []
        seenVisibleBarcodes = []
        hapticEngine?.stop()
        
        Task {
            await scannerSession.destroy()
        }
    }
    
    private func playHaptic(player: CHHapticPatternPlayer?) {
        guard let hapticEngine, let player else {
            return
        }
        
        do {
            hapticEngine.notifyWhenPlayersFinished { _ in .stopEngine }
            
            try hapticEngine.start()
            try player.start(atTime: 0)
        } catch {
            print("Couldn't play haptic: \(error)")
        }
    }
}
