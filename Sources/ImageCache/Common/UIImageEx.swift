//
//  UIImageEx.swift
//  CacheImage
//
//  Created by Do Thang on 16/12/2022.
//

import UIKit
import ImageIO

// MARK: - Optimize image to display

extension UIImage {
    func decodedImage() -> UIImage {
        guard let cgImage = cgImage else { return self }
        let size = CGSize(width: cgImage.width, height: cgImage.height)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(data: nil, width: Int(size.width), height: Int(size.height), bitsPerComponent: 8, bytesPerRow: cgImage.bytesPerRow, space: colorSpace, bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)
        context?.draw(cgImage, in: CGRect(origin: .zero, size: size))
        guard let decodedImage = context?.makeImage() else { return self }
        return UIImage(cgImage: decodedImage)
    }
}

// https://swiftsenpai.com/development/reduce-uiimage-memory-footprint/
struct ImageIOHelper {
    /// Downsampling Using ImageIO
    /// - Parameters:
    ///   - fileUrl: The image URL. It can be a web URL or a local image path.
    ///   - pointSize: The desired size of the downsampled image. Usually, this will be the UIImageView‘s frame size.
    ///   - scale: The downsampling scale factor. Usually, this will be the scale factor associated with the screen (we usually refer to it as @2x or @3x). That’s why you can see that its default value has been set to UIScreen.main.scale
    /// - Returns: downsample image
    static func downsample(imageAt imageUrl: URL,
                           to pointSize: CGSize,
                           scale: CGFloat = UIScreen.main.scale) -> UIImage? {
        let imageSourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary
        guard let imageSource = CGImageSourceCreateWithURL(imageUrl as CFURL, imageSourceOptions) else {
            return nil
        }
        
        return Self.downsample(imageFrom: imageSource, to: pointSize, scale: scale)
    }
    
    /// Downsampling Using ImageIO
    /// - Parameters:
    ///   - data: The image data
    ///   - pointSize: The desired size of the downsampled image. Usually, this will be the UIImageView‘s frame size.
    ///   - scale: The downsampling scale factor. Usually, this will be the scale factor associated with the screen (we usually refer to it as @2x or @3x). That’s why you can see that its default value has been set to UIScreen.main.scale
    /// - Returns: downsample image
    static func downsample(imageFrom data: Data,
                           to pointSize: CGSize,
                           scale: CGFloat = UIScreen.main.scale) -> UIImage? {
        let imageSourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary
        guard let imageSource = CGImageSourceCreateWithData(data as CFData, imageSourceOptions) else {
            return nil
        }
        
        return Self.downsample(imageFrom: imageSource, to: pointSize, scale: scale)
    }
    
    /// Downsampling Using ImageIO
    /// - Parameters:
    ///   - imageSource: The CGImageSource it can be create from imageUrl (CGImageSourceCreateWithURL) or data (CGImageSourceCreateWithData)
    ///   - pointSize: The desired size of the downsampled image. Usually, this will be the UIImageView‘s frame size.
    ///   - scale: The downsampling scale factor. Usually, this will be the scale factor associated with the screen (we usually refer to it as @2x or @3x). That’s why you can see that its default value has been set to UIScreen.main.scale
    /// - Returns: downsample image
    static func downsample(imageFrom imageSource: CGImageSource,
                           to pointSize: CGSize,
                           scale: CGFloat = UIScreen.main.scale) -> UIImage? {
        // Calculate the desired dimension
        let maxDimensionInPixels = max(pointSize.width, pointSize.height) * scale
        
        let downsampleOptions = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceShouldCacheImmediately: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceThumbnailMaxPixelSize: maxDimensionInPixels,
        ] as CFDictionary
        
        let scaledImage = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, downsampleOptions)
        return scaledImage.map { UIImage(cgImage: $0) }
    }
}
