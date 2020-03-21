//
//  CameraView.swift
//
//
//  Created by Brett Fazio on 3/21/20.
//

import SwiftUI
import UIKit
import AVFoundation

struct CameraView: View {
    private var delegate: CameraViewDelegate?
    private var cameraType: AVCaptureDevice.DeviceType
    private var cameraPosition: AVCaptureDevice.Position
    
    init(delegate: CameraViewDelegate? = nil, cameraType: AVCaptureDevice.DeviceType = .builtInWideAngleCamera, cameraPosition: AVCaptureDevice.Position = .back) {
        self.delegate = delegate
        self.cameraType = cameraType
        self.cameraPosition = cameraPosition
    }
    
    var body: some View {
        PreviewHolder(delegate: delegate, cameraType: cameraType, cameraPosition: cameraPosition)
    }
}

class PreviewView: UIView {
    
    private var delegate: CameraViewDelegate?
    
    private var captureSession: AVCaptureSession?
    
    var videoPreviewLayer: AVCaptureVideoPreviewLayer {
        return layer as! AVCaptureVideoPreviewLayer
    }
    
    init(delegate: CameraViewDelegate? = nil, cameraType: AVCaptureDevice.DeviceType = .builtInWideAngleCamera, cameraPosition: AVCaptureDevice.Position = .back) {
        super.init(frame: .zero)
        
        self.delegate = delegate
        
        var accessAllowed = false
        
        let blocker = DispatchGroup()
        blocker.enter()
        
        AVCaptureDevice.requestAccess(for: .video) { (flag) in
            accessAllowed = true
            delegate?.cameraAccessGranted()
            blocker.leave()
        }
        
        blocker.wait()
        
        if !accessAllowed {
            delegate?.cameraAccessDenied()
            return
        }
        
        let session = AVCaptureSession()
        session.beginConfiguration()
        let videoDevice = AVCaptureDevice.default(cameraType,
                                                  for: .video, position: cameraPosition)
        
        guard videoDevice != nil, let videoDeviceInput = try? AVCaptureDeviceInput(device: videoDevice!), session.canAddInput(videoDeviceInput) else {
            delegate?.noCameraDetected()
            return
        }
        session.addInput(videoDeviceInput)
        session.commitConfiguration()
        
        self.captureSession = session
        delegate?.cameraSessionStarted()
    }
    
    override class var layerClass: AnyClass {
        AVCaptureVideoPreviewLayer.self
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        if nil != self.superview {
            self.videoPreviewLayer.session = self.captureSession
            self.videoPreviewLayer.videoGravity = .resizeAspect
            self.captureSession?.startRunning()
        } else {
            self.captureSession?.stopRunning()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) not implemented")
    }
}

struct PreviewHolder: UIViewRepresentable {
    private var delegate: CameraViewDelegate?
    private var cameraType: AVCaptureDevice.DeviceType
    private var cameraPosition: AVCaptureDevice.Position
    
    init(delegate: CameraViewDelegate? = nil, cameraType: AVCaptureDevice.DeviceType = .builtInWideAngleCamera, cameraPosition: AVCaptureDevice.Position = .back) {
        self.delegate = delegate
        self.cameraType = cameraType
        self.cameraPosition = cameraPosition
    }
    
    func makeUIView(context: UIViewRepresentableContext<PreviewHolder>) -> PreviewView {
        PreviewView(delegate: delegate, cameraType: cameraType, cameraPosition: cameraPosition)
    }
    
    func updateUIView(_ uiView: PreviewView, context: UIViewRepresentableContext<PreviewHolder>) {
    }
    
    typealias UIViewType = PreviewView
}

struct CameraView_Previews: PreviewProvider {
    static var previews: some View {
        CameraView()
    }
}
