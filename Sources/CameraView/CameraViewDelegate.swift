//
//  CameraViewDelegate.swift
//  
//
//  Created by Brett Fazio on 3/21/20.
//

import Foundation

protocol CameraViewDelegate {
    func cameraAccessGranted()
    func cameraAccessDenied()
    func noCameraDetected()
    func cameraSessionStarted()
}
