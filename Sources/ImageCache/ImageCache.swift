//
//  ImageCache.swift
//  ImageCache
//
//  Created by Do Thang on 16/12/2022.
//

import UIKit
import Cache

public class ImageCache {
    public typealias Handler = (Result<UIImage, Error>, URL) -> Void
    
    public static let shared = ImageCache(config: .init(countLimit: 50, memoryLimit: 50 * 1024 * 1024))
    
    private let loader: OptimizedImageLoader
    private let config: Config
    
    public init(config: Config) {
        let cache = Cache<String, UIImage>(config: config.cacheConfig)
        let executeQueue = OperationQueue()
        executeQueue.maxConcurrentOperationCount = config.maxConcurrentCount
        self.loader = OptimizedImageLoader(cache: cache, executeQueue: executeQueue, receiveQueue: .main)
        self.config = config
    }
    
    public func setup(config: Config) {
        let cache = Cache<String, UIImage>(config: config.cacheConfig)
        let executeQueue = OperationQueue()
        executeQueue.maxConcurrentOperationCount = config.maxConcurrentCount
        self.loader.config(cache: cache, executeQueue: executeQueue)
    }
}

// MARK: - public methods
extension ImageCache {
    /// Load image from url
    /// - Parameters:
    ///   - url: url to load
    ///   - preferredSize: preferred size for image (ussually UIImageView's size)
    ///   - keepOnlyLatestHandler: true => just keep the latest handler for pendingHandlers, otherwise keep all handlers
    ///   - isLog: log or not
    ///   - completion: handler
    public func loadImage(from url: URL,
                          preferredSize: CGSize? = nil,
                          keepOnlyLatestHandler: Bool = false,
                          isLog: Bool = false,
                          completion: @escaping Handler) {
        let key = self.key(from: url, preferredSize: preferredSize)
        loader.loadValue(from: url, keepOnlyLatestHandler: keepOnlyLatestHandler, isLog: isLog, keyGenerator: { key }) { result, resultUrl in
            switch result {
            case let .success(value):
                completion(.success(value), resultUrl)
            case let .failure(error):
                completion(.failure(error), resultUrl)
            }
        }
    }
    
    /// Get cache image
    /// - Parameter url: url to get
    ///     - preferredSize: preferred size for image (ussually UIImageView's size)
    /// - Returns: image
    public func cacheImage(for url: URL,
                           preferredSize: CGSize? = nil) -> UIImage? {
        let key = self.key(from: url, preferredSize: preferredSize)
        return loader.cacheValue(for: key)
    }
    
    /// Remove all pending handlers that you don't want to notify to them anymore
    public func removePendingHandlers(for url: URL, keepLatestHandler: Bool = false) {
        loader.removePendingHandlers(for: url, keepLatestHandler: keepLatestHandler)
    }
    
    /// Cancel all operations
    public func cancelAll() {
        loader.cancelAll()
    }
    
    /// Remove all cache values
    public func removeCache() {
        loader.removeCache()
    }
    
    /// Key generate from url and preferredSize
    private func key(from url: URL, preferredSize: CGSize? = nil) -> String {
        let sizeString = preferredSize.map { "\($0)" }
        return [url.absoluteString, sizeString].compactMap { $0 }.joined(separator: "_")
    }
}


// MARK: - Define config

public extension ImageCache {
    struct Config {
        let countLimit: Int     // limit number of cache items
        let memoryLimit: Int    // limit memory cache in bytes (100 * 1024 * 1024 = 100MB)
        let showLog: Bool       // To show log or not
        let maxConcurrentCount: Int
        
        public init(countLimit: Int, memoryLimit: Int, showLog: Bool = false, maxConcurrentCount: Int = 6) {
            self.countLimit = countLimit
            self.memoryLimit = memoryLimit
            self.showLog = showLog
            self.maxConcurrentCount = 6
        }
        
        var cacheConfig: Cache<String, UIImage>.Config {
            let config = Cache<String, UIImage>.Config(countLimit: countLimit, memoryLimit: memoryLimit, showLog: showLog)
            return config
        }
    }
}
