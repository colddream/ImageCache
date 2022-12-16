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
        let cache = Cache<URL, UIImage>(config: config.cacheConfig)
        let executeQueue = OperationQueue()
        executeQueue.maxConcurrentOperationCount = config.maxConcurrentCount
        self.loader = OptimizedImageLoader(cache: cache, executeQueue: executeQueue, receiveQueue: .main)
        self.config = config
    }
    
    public func setup(config: Config) {
        let cache = Cache<URL, UIImage>(config: config.cacheConfig)
        let executeQueue = OperationQueue()
        executeQueue.maxConcurrentOperationCount = config.maxConcurrentCount
        self.loader.config(cache: cache, executeQueue: executeQueue)
    }
}

// MARK: - public methods
extension ImageCache {
    public func loadImage(from url: URL,
                          keepOnlyLatestHandler: Bool = false,
                          isLog: Bool = false,
                          completion: @escaping Handler) {
        loader.loadValue(from: url, keepOnlyLatestHandler: keepOnlyLatestHandler, isLog: isLog) { result, resultUrl in
            switch result {
            case let .success(value):
                completion(.success(value), resultUrl)
            case let .failure(error):
                completion(.failure(error), resultUrl)
            }
        }
    }
    
    public func cacheImage(for url: URL) -> UIImage? {
        return loader.cacheValue(for: url)
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
        
        var cacheConfig: Cache<URL, UIImage>.Config {
            let config = Cache<URL, UIImage>.Config(countLimit: countLimit, memoryLimit: memoryLimit, showLog: showLog)
            return config
        }
    }
}
