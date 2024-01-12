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
    
    func makeUIViewController(context: Context) -> ScannerVC {
        ScannerVC(scannerDelegate: context.coordinator)
    }
    
    func updateUIViewController(_ uiViewController: ScannerVC, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator()       // now coordinator is listening to scanner vc
    }
    
    // 1. created coordinator,
    // 2. made it conform to scannerVCDelegate,
    // 3. implement delegate methods,
    // 4. then do something with the info we get
    
    final class Coordinator: NSObject, ScannerVCDelegate {
        func didFind(barcode: String) {
            print(barcode)
        }
        
        func didSurface(error: CameraError) {
            print(error.rawValue)
        }
        
        
    }
    
//    typealias UIViewControllerType = ScannerVC
    
    
}

#Preview {
    ScannerView()
}
