//
//  ScannerViewModel.swift
//  UnifiedScan
//
//  Created by Sunil Vakotar on 07/08/2024.
//

import SwiftUI

class ScannerViewModel: ObservableObject {
    @Published var scannedBarcode: String?
    @Published var scannedMRZ: String?
    @Published var isScanningBarcode = true

    var coordinator: UnifiedCameraView.Coordinator?

    func stopSession() {
        coordinator?.stopSession()
    }
}

