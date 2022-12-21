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
    public static let shared = try! ImageCache(config: .init(type: .memory(.init(countLimit: 100, totalCostLimit: 100 * 1024 * 1024)), clearCacheType: .memoryOnly))
    
    private let loader: OptimizedImageLoader
    private var config: Config
    
    public init(config: Config) throws {
        let cache = try Self.createCache(from: config)
        let executeQueue = OperationQueue()
        executeQueue.maxConcurrentOperationCount = config.maxConcurrentCount
        self.loader = OptimizedImageLoader(cache: cache,
                                           config: .init(showLog: config.showLog, keepOnlyLatestHandler: config.keepOnlyLatestHandler, useOriginalData: config.useOriginalData),
                                           executeQueue: executeQueue)
        self.config = config
    }
    
    public func setup(config: Config) throws {
        self.config = config
        let cache = try Self.createCache(from: config)
        let executeQueue = OperationQueue()
        executeQueue.maxConcurrentOperationCount = config.maxConcurrentCount
        self.loader.config(cache: cache,
                           config: .init(showLog: config.showLog, keepOnlyLatestHandler: config.keepOnlyLatestHandler, useOriginalData: config.useOriginalData),
                           executeQueue: executeQueue)
    }
    
    private static func createCache(from config: Config) throws -> any Cacheable<String, UIImage> {
        let cache: any Cacheable<String, UIImage>
        
        switch config.type {
        case let .memory(config):
            cache = MemoryStorage(config: config)
        case let .disk(config):
            cache = try DiskStorage(config: config)
        case let .both(memoryConfig, diskConfig):
            let memory = MemoryStorage(config: memoryConfig)
            let disk = try DiskStorage(config: diskConfig)
            cache = Cache<UIImage>(type: .storages(memory: memory, disk: disk),
                                   config: .init(clearCacheType: config.clearCacheType, showLog: config.showLog))
        }
        
        return cache
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
                          completion: @escaping Handler) {
        let key = self.key(from: url, preferredSize: preferredSize)
        
        loader.loadValue(from: url, key: key, dataTransformHanler: { [weak self] data in
            if self?.config.useDownsampleImage == true,
                let size = preferredSize {
                return ImageIOHelper.downsample(imageFrom: data, to: size)
            }
            return nil
        }, completion: { result, resultUrl in
            switch result {
            case let .success(value):
                completion(.success(value), resultUrl)
            case let .failure(error):
                completion(.failure(error), resultUrl)
            }
        })
    }
    
    /// Get cache image
    /// - Parameter url: url to get
    ///     - preferredSize: preferred size for image (ussually UIImageView's size)
    /// - Returns: image
    public func cacheImage(for url: URL, preferredSize: CGSize? = nil) throws -> UIImage? {
        let key = self.key(from: url, preferredSize: preferredSize)
        return try loader.cacheValue(for: key)
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
    public func removeCache() throws {
        try loader.removeCache()
    }
    
    /// Key generate from url and preferredSize
    private func key(from url: URL, preferredSize: CGSize? = nil) -> String {
        let sizeString = preferredSize.map { "\($0)" }
        return [url.absoluteString, sizeString].compactMap { $0 }.joined(separator: "_")
    }
}


// MARK: - Define config

extension ImageCache {
    public struct Config {
        public enum CacheType {
            case memory(MemoryStorage<String, UIImage>.Config)
            case disk(DiskStorage<UIImage>.Config)
            case both(memory: MemoryStorage<String, UIImage>.Config, disk: DiskStorage<UIImage>.Config)
        }
        
        // Cache Type
        let type: CacheType
        
        // Clear cache type
        let clearCacheType: Cache<UIImage>.Config.ClearCacheType
        
        // Show log
        let showLog: Bool
        
        // max concurrent count for executeQueue
        let maxConcurrentCount: Int
        
        // keep only lastest handler
        let keepOnlyLatestHandler: Bool
        
        // Use original data for set cache value
        let useOriginalData: Bool
        
        // Use downsample image (https://swiftsenpai.com/development/reduce-uiimage-memory-footprint/)
        let useDownsampleImage: Bool
        
        public init(type: CacheType, clearCacheType: Cache<UIImage>.Config.ClearCacheType,
                    showLog: Bool = false, maxConcurrentCount: Int = 6,
                    keepOnlyLatestHandler: Bool = false, useOriginalData: Bool = false,
                    useDownsampleImage: Bool = false) {
            self.type = type
            self.clearCacheType = clearCacheType
            self.showLog = showLog
            self.maxConcurrentCount = maxConcurrentCount
            self.keepOnlyLatestHandler = keepOnlyLatestHandler
            self.useOriginalData = useOriginalData
            self.useDownsampleImage = useDownsampleImage
        }
    }
}
