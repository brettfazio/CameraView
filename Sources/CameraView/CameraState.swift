//
//  File.swift
//  
//
//  Created by Brett Fazio on 3/25/20.
//

import Foundation
import UIKit

public class CameraState : NSObject, ObservableObject {
    @Published public var capturedImage : UIImage?
    @Published public var capturedImageError : Error?
}
