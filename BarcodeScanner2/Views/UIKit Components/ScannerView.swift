//
//  ScannerView.swift
//  BarcodeScanner2
//
//  Created by lexi sanders on 1/12/24.
//

import SwiftUI

// 1. make view controller
// 2. update view controller

struct ScannerView: UIViewControllerRepresentable {
    
    @Binding var scannedCode: String // updates scannedCode variable in the BarcodeScannerView
    @Binding var alertItem: AlertItem?
    
    func makeUIViewController(context: Context) -> ScannerVC {
        ScannerVC(scannerDelegate: context.coordinator)
    }
    
    func updateUIViewController(_ uiViewController: ScannerVC, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(scannerView: self)       // now coordinator is listening to scanner vc
    }
    
    // 1. created coordinator,
    // 2. made it conform to scannerVCDelegate,
    // 3. implement delegate methods,
    // 4. then do something with the info we get
    
    final class Coordinator: NSObject, ScannerVCDelegate {
        
        // create connection to scanneView
        private let scannerView: ScannerView
        
        init(scannerView: ScannerView) {
            self.scannerView = scannerView
        }
        
        func didFind(barcode: String) {
            scannerView.scannedCode = barcode    // telling scanner view what the barcode is
        }
        
        func didSurface(error: CameraError) {
            switch error {
            case .invalidDeviceInput: scannerView.alertItem = AlertContext.invalidDeviceInput
            case .invalidScannedValue: scannerView.alertItem = AlertContext.invalidScannedType
            }
        }
        
        
    }
    
//    typealias UIViewControllerType = ScannerVC
    
    
}

