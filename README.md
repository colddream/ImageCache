
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
let imageCache = try ImageCache(config: .init(type: .both(memory: .init(countLimit: 100, totalCostLimit: 100 * 1024 * 1024),
                                                          disk: .init(name: "ImageCacheTests_ImageCache", sizeLimit: 0)),
                                              clearCacheType: .both))
```

```swift
imageCache.loadImage(from: URL(string: urlString)!) { result, resultUrl in
    print("Finished Load for: \(urlString)")
    switch result {
    case .success(let image):
        print("\(image)")
    case .failure(let error):
        print("\(error.localizedDescription)")
    }
}
```
