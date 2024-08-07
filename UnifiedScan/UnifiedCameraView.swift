//
//  UnifiedCameraView.swift
//  UnifiedScan
//
//  Created by Sunil Vakotar on 06/08/2024.
//

import SwiftUI
import UIKit

struct UnifiedCameraView: UIViewControllerRepresentable {
    @ObservedObject var viewModel: ScannerViewModel

    func makeUIViewController(context: Context) -> UnifiedScannerViewController {
        let viewController = UnifiedScannerViewController()
        viewController.delegate = context.coordinator
        context.coordinator.viewController = viewController // Save the reference
        viewModel.coordinator = context.coordinator // Set the coordinator in view model
        return viewController
    }

    func updateUIViewController(_ uiViewController: UnifiedScannerViewController, context: Context) {
        uiViewController.isScanningBarcode = viewModel.isScanningBarcode
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self, viewModel: viewModel)
    }

    class Coordinator: NSObject, UnifiedScannerViewControllerDelegate {
        var parent: UnifiedCameraView
        var viewModel: ScannerViewModel
        weak var viewController: UnifiedScannerViewController?

        init(_ parent: UnifiedCameraView, viewModel: ScannerViewModel) {
            self.parent = parent
            self.viewModel = viewModel
        }

        func unifiedScannerViewController(_ viewController: UnifiedScannerViewController, didDetectBarcode barcode: String) {
            viewModel.scannedBarcode = barcode
        }

        func unifiedScannerViewController(_ viewController: UnifiedScannerViewController, didDetectMRZ mrz: String) {
            viewModel.scannedMRZ = mrz
        }

        func startSession() {
            viewController?.startSession()
        }

        func stopSession() {
            viewController?.stopSession()
        }
    }
}
