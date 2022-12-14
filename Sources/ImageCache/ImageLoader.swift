//
//  ImageLoader.swift
//  ImageCache
//
//  Created by Do Thang on 08/12/2022.
//

import UIKit
import Cache

public class ImageLoader: CacheLoader {
    public static let shared = ImageLoader(cache: Cache<URL, UIImage>(config: .init(countLimit: 100, memoryLimit: 50 * 1024 * 1024)),
                                           executeQueue: OperationQueue(),
                                           receiveQueue: .main)
    
    // MARK: - CacheLoader methods
    
    public var cache: any Cacheable<URL, UIImage>
    
    public var executeQueue: OperationQueue
    
    public var receiveQueue: OperationQueue
    
    public var session: URLSession
    
    public var loadingUrls: [URL : Bool] = [:]
    
    public var pendingHandlers: [URL : [Handler]] = [:]
    
    // Init
    public init(cache: any Cacheable<URL, UIImage>,
                executeQueue: OperationQueue,
                receiveQueue: OperationQueue = .main) {
        self.cache = cache
        self.executeQueue = executeQueue
        self.receiveQueue = receiveQueue
        self.session = Self.regenerateSession(receiveQueue: receiveQueue)
    }
}

// MARK: - CacheLoader methods

extension ImageLoader {
    public func value(from data: Data) -> UIImage? {
        return UIImage(data: data)
    }
}
