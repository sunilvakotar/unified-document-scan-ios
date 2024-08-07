//
//  ScannerView.swift
//  UnifiedScan
//
//  Created by Sunil Vakotar on 06/08/2024.
//

import SwiftUI

struct ScannerView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var viewModel: ScannerViewModel

    var body: some View {
        ZStack {
            UnifiedCameraView(viewModel: viewModel)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                Spacer()
                
                HStack {
                    Button(action: {
                        viewModel.isScanningBarcode = true
                    }) {
                        Text("Barcode")
                            .padding()
                            .background(viewModel.isScanningBarcode ? Color.blue : Color.gray)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    
                    Button(action: {
                        viewModel.isScanningBarcode = false
                    }) {
                        Text("Passport")
                            .padding()
                            .background(!viewModel.isScanningBarcode ? Color.blue : Color.gray)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                .padding(.bottom, 20)
                
                Button(action: {
                    viewModel.stopSession()
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Cancel")
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.bottom, 20)
            }
        }
        .onChange(of: viewModel.scannedBarcode) { newValue in
            if newValue != nil {
                viewModel.stopSession()
                presentationMode.wrappedValue.dismiss()
            }
        }
        .onChange(of: viewModel.scannedMRZ) { newValue in
            if newValue != nil {
                viewModel.stopSession()
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
}



