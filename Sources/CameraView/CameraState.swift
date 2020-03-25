//
//  File.swift
//  
//
//  Created by Brett Fazio on 3/25/20.
//

import Foundation
import UIKit

class CameraState : NSObject, ObservableObject {
    @Published var capturedImage : UIImage?
    @Published var capturedImageError : Error?
}
