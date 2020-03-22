<p align="center">
    <img src="https://img.shields.io/badge/platform-iOS%2013%2B-blue.svg?style=flat" alt="Platform: iOS 13.0+"/>
    <a href="https://developer.apple.com/swift"><img src="https://img.shields.io/badge/language-swift%205.1-4BC51D.svg?style=flat" alt="Language: Swift 5.1" /></a>
</p>

# CameraView for SwiftUI 📷

CameraView allows you to have a SnapChat-style screen on your SwiftUI app that gives a realtime view of the iPhone camera.

## Adding CameraView to your App

In your Xcode project go to `File -> Swift Packages -> Add Package Dependency` 

And enter
```
https://github.com/brettfazio/CameraView
```

As the url. You've now integrated the 📷🪟 into your app!

## Usage

In your SwiftUI view simply add it in like you would any other view.

Here's an example adding it to a simple view called `HomeView`

```
import SwiftUI
import CameraView

struct HomeView: View {
    var body: some View {
        NavigationView {
            VStack {
              CameraView()
            }
        }
    }
}

```

Without any initializers, `CameraView` will be initialized without a delegate, the `.builtInWideAngleCamera`, and the back camera (`.back`).

To set those values use the following init method with whatever parameters you want:

```
CameraView(delegate: delegate, cameraType: .builtInDualCamera, cameraPosition: .back)
```

## Requirements

iOS 13.0+
