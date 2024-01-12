//
//  ScannerVC.swift
//  BarcodeScanner2
//
//  Created by lexi sanders on 1/12/24.
//

import UIKit
import AVFoundation

// list of commands apart of delegate
protocol ScannerVCDelegate: AnyObject {
    func didFind(barcode: String)
}

final class ScannerVC: UIViewController {
    
    let captureSession = AVCaptureSession()  // what is captured from the camera
    var previewLayer: AVCaptureVideoPreviewLayer?
    weak var scannerDelegate: (ScannerVCDelegate)?
    
    init(scannerDelegate: ScannerVCDelegate) {
        super.init(nibName: nil, bundle: nil)
        self.scannerDelegate = scannerDelegate
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    private func setupCaptureSession() {
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {
            return
        }
        
        let videoInput: AVCaptureDeviceInput
        
        do {
            try videoInput = AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return
        }
        
        // if we can get input from the device
        if captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
        } else {
            return
        }
        
        // what gets scanned
        let metaDataOutput = AVCaptureMetadataOutput()
        
        // if we can add output
        if captureSession.canAddOutput(metaDataOutput) {
            captureSession.addOutput(metaDataOutput) // add it
            metaDataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main) // set delegate
            metaDataOutput.metadataObjectTypes = [.ean8, .ean13]  // an array of type of barcode we want to scan
        } else {
            return
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer!.videoGravity = .resizeAspectFill    // fill view but keep aspect ratio
        view.layer.addSublayer(previewLayer!)
        
        captureSession.startRunning()
    }
    
}

// conform to delegate
extension ScannerVC: AVCaptureMetadataOutputObjectsDelegate {
    
    // tell delegate the barcode that we find
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        guard let object = metadataObjects.first else {         //  do we have metadata object in array    get first item/barcode in array
            return
        }
        
        guard let machineReadableObject = object as? AVMetadataMachineReadableCodeObject else {     // is it this machine readable code object
            return
        }
        
        guard let barcode = machineReadableObject.stringValue else { // get the string value of the machine readable object
            return
        }
        
        scannerDelegate?.didFind(barcode: barcode)  // send string value to delegate
    }
    
}
