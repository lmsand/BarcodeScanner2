//
//  ScannerVC.swift
//  BarcodeScanner2
//
//  Created by lexi sanders on 1/12/24.
//

import UIKit
import AVFoundation

enum CameraError: String {
    case invalidDeviceInput = "Something is wrong with the camera. We are unable to capture the input."
    case invalidScannedValue = "The value scanned is not valid. This app scans EAN-8 and EAN-13."
}

// list of commands apart of delegate
protocol ScannerVCDelegate: AnyObject {
    func didFind(barcode: String)
    func didSurface(error: CameraError)
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCaptureSession()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        guard let previewLayer = previewLayer else {            // if no preview layer yet, return error, takes away optional
            scannerDelegate?.didSurface(error: .invalidDeviceInput)
            return
        }
        
        previewLayer.frame = view.layer.bounds
    }
    
    private func setupCaptureSession() {
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {
            scannerDelegate?.didSurface(error: .invalidDeviceInput)
            return
        }
        
        let videoInput: AVCaptureDeviceInput
        
        do {
            try videoInput = AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            scannerDelegate?.didSurface(error: .invalidDeviceInput)
            return
        }
        
        // if we can get input from the device
        if captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
        } else {
            scannerDelegate?.didSurface(error: .invalidDeviceInput)
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
            scannerDelegate?.didSurface(error: .invalidDeviceInput)
            return
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer!.videoGravity = .resizeAspectFill    // fill view but keep aspect ratio
        view.layer.addSublayer(previewLayer!)
        
     
        DispatchQueue.global().async { [weak self] in
            self?.captureSession.startRunning()
        }
    }
    
}

// conform to delegate
extension ScannerVC: AVCaptureMetadataOutputObjectsDelegate {
    
    // tell delegate the barcode that we find
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        guard let object = metadataObjects.first else {         //  do we have metadata object in array    get first item/barcode in array
            scannerDelegate?.didSurface(error: .invalidScannedValue)
            return
        }
        
        guard let machineReadableObject = object as? AVMetadataMachineReadableCodeObject else {     // is it this machine readable code object
            scannerDelegate?.didSurface(error: .invalidScannedValue)
            return
        }
        
        guard let barcode = machineReadableObject.stringValue else { // get the string value of the machine readable object
            scannerDelegate?.didSurface(error: .invalidScannedValue)
            return
        }
        
        scannerDelegate?.didFind(barcode: barcode)  // send string value to delegate
    }
    
}
