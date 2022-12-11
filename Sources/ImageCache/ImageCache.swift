////
////  ImageCache.swift
////  ImageCache
////
////  Created by Do Thang on 08/12/2022.
////
//
//import UIKit
//
//// In-Memory Cache
//public protocol ImageCacheType: AnyObject {
//    func image(for url: URL) -> UIImage?
//    func setImage(_ image: UIImage?, for url: URL)
//    func removeImage(for url: URL)
//    func removeCache()
//    
//    subscript(_ url: URL) -> UIImage? { get set }
//}
//
//
//public class ImageCache {
//    public struct Config {
//        public static let defaultConfig = Config(countLimit: 100, memoryLimit: 1024 * 1024 * 100) // 100 MB
//        
//        let countLimit: Int
//        let memoryLimit: Int
//        
//        public init(countLimit: Int, memoryLimit: Int) {
//            self.countLimit = countLimit
//            self.memoryLimit = memoryLimit
//        }
//    }
//    
//    private lazy var imageCache: NSCache<AnyObject, AnyObject> = {
//        let cache = NSCache<AnyObject, AnyObject>()
//        cache.countLimit = config.countLimit
//        cache.totalCostLimit = config.memoryLimit
//        return cache
//    }()
//    private let lock = NSLock()
//    
//    private let config: Config
//    
//    public init(config: Config = Config.defaultConfig) {
//        self.config = config
//    }
//}
//
//// MARK: - ImageCacheType
//
//extension ImageCache: ImageCacheType {
//    public func image(for url: URL) -> UIImage? {
//        lock.lock()
//        defer { lock.unlock() }
//        
//        let image = imageCache.object(forKey: url as AnyObject) as? UIImage
//        return image
//    }
//    
//    public func setImage(_ image: UIImage?, for url: URL) {
//        guard let image = image else {
//            return removeImage(for: url)
//        }
//        
//        lock.lock()
//        defer { lock.unlock() }
//        
//        imageCache.setObject(image, forKey: url as AnyObject)
//    }
//    
//    public func removeImage(for url: URL) {
//        lock.lock()
//        defer { lock.unlock() }
//        
//        imageCache.removeObject(forKey: url as AnyObject)
//    }
//    
//    public func removeCache() {
//        lock.lock()
//        defer { lock.unlock() }
//        
//        imageCache.removeAllObjects()
//    }
//    
//    public subscript(url: URL) -> UIImage? {
//        get {
//            image(for: url)
//        }
//        set {
//            setImage(newValue, for: url)
//        }
//    }
//}
