//
//  BarcodeScannerViewModel.swift
//  BarcodeScanner2
//
//  Created by lexi sanders on 1/12/24.
//

import SwiftUI

final class BarcodeScannerViewModel: ObservableObject {
    @Published var scannedCode = "" // when scannedCode changes the view will get updated
    @Published var alertItem: AlertItem?
    
    var statusText: String {
        scannedCode.isEmpty ? "Not Yet Scanned" : scannedCode
    }
    
    var statusTextColor: Color {
        scannedCode.isEmpty ? .red : .green
    }
}

