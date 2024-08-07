//
//  ContentView.swift
//  UnifiedScan
//
//  Created by Sunil Vakotar on 06/08/2024.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = ScannerViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
                if let barcode = viewModel.scannedBarcode {
                    Text("Scanned Barcode: \(barcode)")
                        .padding()
                        .background(Color.white)
                        .foregroundColor(Color.black)
                        .cornerRadius(10)
                        .padding()
                }
                
                if let mrz = viewModel.scannedMRZ {
                    Text("Scanned Document: \(mrz)")
                        .padding()
                        .background(Color.white)
                        .foregroundColor(Color.black)
                        .cornerRadius(10)
                        .padding()
                }
                
                NavigationLink(destination: ScannerView().environmentObject(viewModel)) {
                    Text("Start Scanning")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .navigationBarTitle("Unified Scanner")
        }
    }
}

#Preview {
    ContentView()
}
