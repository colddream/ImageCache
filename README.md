
# Introduction

**ImageCache** is an open-source support for caching image.


# Installation

ImageCache is packaged as a dynamic framework that you can import into your Xcode project. You can install this manually, or by using Swift Package Manager.

**Note:** ImageCache requires Xcode 13+ to build, and runs on iOS 11+.

To install using Swift Package Manage, add this to the `dependencies:` section in your Package.swift file:

```swift
.package(url: "https://github.com/colddream/ImageCache", .upToNextMinor(from: "1.0.0")),
```


# Usage

You can create an instance of **ImageLoader** as follows:

```swift
let imageLoader = ImageLoader(cache: ImageCache())
```

```swift
imageLoader.loadImage(from: URL(string: urlString)!) { result in
    print("Finished Load for: \(urlString)")
    switch result {
    case .success(let image):
        print("\(image)")
    case .failure(let error):
        print("\(error.localizedDescription)")
    }
}
```
