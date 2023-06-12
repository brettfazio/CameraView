//
//  CameraView.swift
//
//
//  Created by Brett Fazio on 3/21/20.
//

import SwiftUI
import UIKit
import AVFoundation

public struct CameraView: View {
    private var delegate: CameraViewDelegate?
    private var cameraType: AVCaptureDevice.DeviceType
    private var cameraPosition: AVCaptureDevice.Position
    private var preview : PreviewHolder
    
    @ObservedObject private var viewModel : CameraViewModel
    
    public init(delegate: CameraViewDelegate? = nil, cameraType: AVCaptureDevice.DeviceType = .builtInWideAngleCamera, cameraPosition: AVCaptureDevice.Position = .back) {
        self.delegate = delegate
        self.cameraType = cameraType
        self.cameraPosition = cameraPosition
        self.preview = PreviewHolder(delegate: delegate, cameraType: cameraType, cameraPosition: cameraPosition)
        
        self.viewModel = CameraViewModel(preview: self.preview)
    }
    
    public var body: some View {
        preview
    }
    
    public func getViewModel() -> CameraViewModel {
        return self.viewModel
    }
}

extension CameraView {
    public class CameraViewModel : NSObject, ObservableObject {
        @Published var capturedPhoto: UIImage? = nil
        
        private var preview : PreviewHolder
        
        fileprivate init(preview : PreviewHolder) {
            self.preview = preview
        }
        
        public func capturePhoto() {
            preview.getView().capturePhoto()
        }
    }
}

enum PhotoParseError : Error {
    case error(Error)
    case takeRetainValueFailed
}

private class PreviewView: UIView, AVCapturePhotoCaptureDelegate {
    
    @EnvironmentObject var cameraState : CameraState
    
    private var delegate: CameraViewDelegate?
    
    private var captureSession: AVCaptureSession?
    private var videoDeviceInput: AVCaptureDeviceInput?
    private var photoOutput: AVCapturePhotoOutput?
    
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
        
        guard videoDevice != nil, let deviceInput = try? AVCaptureDeviceInput(device: videoDevice!), session.canAddInput(deviceInput) else {
            delegate?.noCameraDetected()
            return
        }
        self.videoDeviceInput = deviceInput
        session.addInput(videoDeviceInput!)
        
        self.photoOutput = AVCapturePhotoOutput()
        photoOutput!.isHighResolutionCaptureEnabled = true
        photoOutput!.isLivePhotoCaptureEnabled = photoOutput!.isLivePhotoCaptureSupported
        
        guard session.canAddOutput(photoOutput!) else {
            delegate?.noCameraDetected()
            return
            
        }
        session.sessionPreset = .photo
        session.addOutput(photoOutput!)
        
        session.commitConfiguration()
        
        self.captureSession = session
        delegate?.cameraSessionStarted()
        self.captureSession?.startRunning()
    }
    
    override class var layerClass: AnyClass {
        AVCaptureVideoPreviewLayer.self
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        if nil != self.superview {
            self.videoPreviewLayer.session = self.captureSession
            self.videoPreviewLayer.videoGravity = .resizeAspectFill
        }
    }
    
    func capturePhoto() {
        let photoSettings: AVCapturePhotoSettings
        if photoOutput!.availablePhotoCodecTypes.contains(.hevc) {
            photoSettings = AVCapturePhotoSettings(format:
                [AVVideoCodecKey: AVVideoCodecType.hevc])
        } else {
            photoSettings = AVCapturePhotoSettings()
        }
        photoSettings.flashMode = .auto
        self.photoOutput?.capturePhoto(with: photoSettings, delegate: self)
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if error != nil {
            cameraState.capturedImageError = PhotoParseError.error(error!)
            return
        }
        
        if let cgImage = photo.previewCGImageRepresentation() {
            let orientation = photo.metadata[kCGImagePropertyOrientation as String] as! NSNumber
            let uiOrientation = UIImage.Orientation(rawValue: orientation.intValue)!
            let image = UIImage(cgImage: cgImage, scale: 1, orientation: uiOrientation)
            cameraState.capturedImage = image
        }else {
            cameraState.capturedImageError = PhotoParseError.takeRetainValueFailed
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) not implemented")
    }
}

private struct PreviewHolder: UIViewRepresentable {
    private var delegate: CameraViewDelegate?
    private var cameraType: AVCaptureDevice.DeviceType
    private var cameraPosition: AVCaptureDevice.Position
    private var view: PreviewView
    
    init(delegate: CameraViewDelegate? = nil, cameraType: AVCaptureDevice.DeviceType = .builtInWideAngleCamera, cameraPosition: AVCaptureDevice.Position = .back) {
        self.delegate = delegate
        self.cameraType = cameraType
        self.cameraPosition = cameraPosition
        self.view = PreviewView(delegate: delegate, cameraType: cameraType, cameraPosition: cameraPosition)
    }
    
    func makeUIView(context: UIViewRepresentableContext<PreviewHolder>) -> PreviewView {
        view
    }
    
    func updateUIView(_ uiView: PreviewView, context: UIViewRepresentableContext<PreviewHolder>) {
    }
    
    func getView() -> PreviewView {
        return self.view
    }
    
    typealias UIViewType = PreviewView
}

public struct CameraView_Previews: PreviewProvider {
    public static var previews: some View {
        CameraView()
    }
}
