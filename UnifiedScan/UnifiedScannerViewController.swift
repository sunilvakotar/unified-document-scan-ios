//
//  UnifiedScannerViewController.swift
//  UnifiedScan
//
//  Created by Sunil Vakotar on 06/08/2024.
//

import UIKit
import AVFoundation
import Vision

protocol UnifiedScannerViewControllerDelegate: AnyObject {
    func unifiedScannerViewController(_ viewController: UnifiedScannerViewController, didDetectBarcode barcode: String)
    func unifiedScannerViewController(_ viewController: UnifiedScannerViewController, didDetectMRZ mrz: String)
}

class UnifiedScannerViewController: UIViewController {
    var session: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    var videoOutput: AVCaptureVideoDataOutput!

    weak var delegate: UnifiedScannerViewControllerDelegate?

    var detectedBarcode: String? {
        didSet {
            if let barcode = detectedBarcode {
                delegate?.unifiedScannerViewController(self, didDetectBarcode: barcode)
            }
        }
    }

    var detectedMRZ: String? {
        didSet {
            if let mrz = detectedMRZ {
                delegate?.unifiedScannerViewController(self, didDetectMRZ: mrz)
            }
        }
    }

    private let sessionQueue = DispatchQueue(label: "sessionQueue")
    private let roiView: UIView = {
        let view = UIView()
        view.layer.borderWidth = 2
        view.layer.borderColor = UIColor.red.cgColor
        view.backgroundColor = UIColor.clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    var isScanningBarcode = true
    private var isScanning = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .black

        setupCamera()
        setupUI()
        requestCameraAccess()
    }

    private func setupCamera() {
        session = AVCaptureSession()
        session.beginConfiguration()

        guard let videoCaptureDevice = AVCaptureDevice.default(.builtInDualWideCamera, for: .video, position: .back) else {
            print("No back camera available")
            return
        }

        do {
            let videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
            if session.canAddInput(videoInput) {
                session.addInput(videoInput)
            } else {
                print("Could not add video input to the session")
            }
        } catch {
            print("Could not create video input: \(error)")
        }

        videoOutput = AVCaptureVideoDataOutput()
        videoOutput.setSampleBufferDelegate(self, queue: sessionQueue)
        if session.canAddOutput(videoOutput) {
            session.addOutput(videoOutput)
        } else {
            print("Could not add video output to the session")
        }

        session.commitConfiguration()
        
        previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = view.layer.bounds
        view.layer.addSublayer(previewLayer)
    }

    private func setupUI() {
        view.addSubview(roiView)
        
        NSLayoutConstraint.activate([
            roiView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            roiView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            roiView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.6),
            roiView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.2)
        ])
        
        let toggleButton = UIButton(type: .system)
        toggleButton.setTitle("Toggle Scan", for: .normal)
        toggleButton.addTarget(self, action: #selector(toggleScanMode), for: .touchUpInside)
        toggleButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(toggleButton)
        
        NSLayoutConstraint.activate([
            toggleButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            toggleButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
    }

    private func requestCameraAccess() {
        AVCaptureDevice.requestAccess(for: .video) { granted in
            if granted {
                self.startSession()
            } else {
                print("Camera access denied")
            }
        }
    }

    func startSession() {
        sessionQueue.async {
            if !self.session.isRunning {
                self.session.startRunning()
            }
        }
    }

    func stopSession() {
        sessionQueue.async {
            if self.session.isRunning {
                self.session.stopRunning()
            }
        }
    }

    @objc private func toggleScanMode() {
        isScanningBarcode.toggle()
    }

    @objc private func toggleScanning() {
        if isScanning {
            stopSession()
        } else {
            startSession()
        }
        isScanning.toggle()
    }
}

extension UnifiedScannerViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }

        if isScanningBarcode {
            let request = VNDetectBarcodesRequest { [weak self] request, error in
                if let results = request.results as? [VNBarcodeObservation], let firstResult = results.first {
                    self?.detectedBarcode = firstResult.payloadStringValue
                }
            }
            performRequest(request, on: pixelBuffer)
        } else {
//            let request = VNDetectTextRectanglesRequest { [weak self] request, error in
//                guard let results = request.results as? [VNTextObservation] else { return }
//                for result in results {
//                    if let candidate = result.topCandidates(1).first, candidate.string.contains("<") {
//                        self?.detectedMRZ = candidate.string
//                    }
//                }
//            }
            let request = VNRecognizeTextRequest { [weak self] request, error in
                guard let results = request.results as? [VNRecognizedTextObservation] else { return }
                for result in results {
                    for candidate in result.topCandidates(1) where candidate.string.contains("<") {
                        self?.detectedMRZ = candidate.string
                        return
                    }
                }
            }
            //request.reportCharacterBoxes = true
            performRequest(request, on: pixelBuffer)
        }
    }

    private func performRequest(_ request: VNRequest, on pixelBuffer: CVPixelBuffer) {
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .up, options: [:])
        do {
            //let roiFrame = previewLayer.metadataOutputRectConverted(fromLayerRect: roiView.frame)
            //request.regionOfInterest = roiFrame
            try handler.perform([request])
        } catch {
            print("Failed to perform request: \(error)")
        }
    }
}


