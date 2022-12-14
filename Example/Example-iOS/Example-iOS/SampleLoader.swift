//
//  SampleLoader.swift
//  Example-iOS
//
//  Created by Do Thang on 14/12/2022.
//

import UIKit
import Cache
import ImageCache

class SampleLoader: CacheLoader {
    static let shared = SampleLoader(cache: Cache<URL, Sample>(config: .init(countLimit: 100, memoryLimit: 50 * 1024 * 1024)),
                                     executeQueue: OperationQueue(),
                                     receiveQueue: .main)
    
    // MARK: - CacheLoader methods
    
    var cache: any Cacheable<URL, Sample>
    
    var executeQueue: OperationQueue
    
    var receiveQueue: OperationQueue
    
    var session: URLSession
    
    var loadingUrls: [URL : Bool] = [:]
    
    var pendingHandlers: [URL : [Handler]] = [:]
    
    // Init
    init(cache: any Cacheable<URL, Sample>,
         executeQueue: OperationQueue,
         receiveQueue: OperationQueue = .main) {
        self.cache = cache
        self.executeQueue = executeQueue
        self.receiveQueue = receiveQueue
        self.session = Self.regenerateSession(receiveQueue: receiveQueue)
    }
}

// MARK: - CacheLoader methods

extension SampleLoader {
    func value(from data: Data) -> Sample? {
        return Sample()
    }
}

struct Sample: Codable {
}
