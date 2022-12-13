//
//  ImageLoader.swift
//  ImageCache
//
//  Created by Do Thang on 08/12/2022.
//

import UIKit
import Cache

public typealias ImageLoaderHandler = (Result<UIImage, Error>) -> Void

public class ImageLoader: NSObject {
    public static let shared = ImageLoader(cache: Cache<URL, UIImage>(config: .init(countLimit: 100, memoryLimit: 50 * 1024 * 1024)),
                                           executeQueue: OperationQueue(),
                                           receiveQueue: .main)
    
    private var cache: any Cacheable<URL, UIImage>
    private var executeQueue: OperationQueue
    private var receiveQueue: OperationQueue
    private var session: URLSession
    
    private var loadingUrls: [URL: Bool] = [:]
    private var pendingHandlers: [URL: [ImageLoaderHandler]] = [:]
    
    // Init
    public init(cache: any Cacheable<URL, UIImage>,
                executeQueue: OperationQueue,
                receiveQueue: OperationQueue = .main) {
        self.cache = cache
        self.executeQueue = executeQueue
        self.receiveQueue = receiveQueue
        self.session = Self.regenerateSession(receiveQueue: receiveQueue)
    }
    
    private static func regenerateSession(receiveQueue: OperationQueue) -> URLSession {
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config, delegate: nil, delegateQueue: receiveQueue)
        return session
    }
}

// MARK: - public methods

extension ImageLoader {
    public func config(cache: any Cacheable<URL, UIImage>,
                executeQueue: OperationQueue,
                receiveQueue: OperationQueue = .main) {
        // Make sure the old operations will be canceled
        self.executeQueue.cancelAllOperations()
        
        // Setup again
        self.cache = cache
        self.executeQueue = executeQueue
        self.receiveQueue = receiveQueue
        self.session = Self.regenerateSession(receiveQueue: receiveQueue)
    }
    
    /// Load image from cache (or from server)
    /// - Parameters:
    ///   - url: url to load image
    ///   - keepOnlyLatestHandler: true => just keep the latest handler for pendingHandlers, otherwise keep all handlers
    ///   - isLog: log or not
    ///   - completion: handler
    public func loadImage(from url: URL,
                          keepOnlyLatestHandler: Bool = false,
                          isLog: Bool = false,
                          completion: @escaping ImageLoaderHandler) {
        if let image = cache[url] {
            logPrint("[ImageLoader] image from cache (\(url.absoluteString))", isLog: isLog)
            completion(.success(image))
            return
        }
        
        // Check if url is already loading
        if loadingUrls[url] == true {
            logPrint("[ImageLoader] waiting previous loading image", isLog: isLog)
            if keepOnlyLatestHandler {
                pendingHandlers[url] = [completion]
            } else {
                let preHandlers = pendingHandlers[url] ?? []
                pendingHandlers[url] = preHandlers + [completion]
            }
            return
        }
        
        loadingUrls[url] = true
        pendingHandlers[url] = [completion]
        logPrint("[ImageLoader] Start get image from server (\(url.absoluteString))", isLog: isLog)
        let operation = DataTaskOperation(session: session, url: url) { [weak self] data, response, error in
            guard let self = self else {
                return
            }
            
            let result: Result<UIImage, Error>
            
            if let error = error {
                result = .failure(error)
                
            } else if let data = data, let image = UIImage(data: data) {
                self.cache[url] = image
                self.logPrint("[ImageLoader] image from server (\(url.absoluteString))", isLog: isLog)
                result = .success(image)
                
            } else {
                let error = CustomError(message: "Invalid Image Data")
                result = .failure(error)
            }

            self.handleResult(result, for: url)
        }
        executeQueue.addOperation(operation)
    }
    
    /// Remove all pending handlers that you don't want to notify to them anymore
    /// - Parameters:
    ///   - url: url to find pending handlers to remove
    ///   - keepLatestHandler: should keep latest handler or not
    public func removePendingHandlers(for url: URL, keepLatestHandler: Bool = false) {
        if let handlers = self.pendingHandlers[url], handlers.count > 0 {
            if keepLatestHandler {
                self.pendingHandlers[url] = [handlers.last!]
            } else {
                self.pendingHandlers[url] = nil
            }
        }
    }
    
    /// Cancel all operations
    public func cancelAll() {
        pendingHandlers.removeAll()
        loadingUrls.removeAll()
        executeQueue.cancelAllOperations()
    }
    
    /// Remove all cache images
    public func removeCache() {
        self.cache.removeAll()
    }
}

// MARK: - Helper methods

extension ImageLoader {
    private func handleResult(_ result: Result<UIImage, Error>, for url: URL) {
        if let handlers = pendingHandlers[url] {
            pendingHandlers[url] = nil
            handlers.forEach { $0(result) }
        }
        loadingUrls[url] = nil
    }
    
    private func logPrint(_ items: Any..., separator: String = " ", terminator: String = "\n", isLog: Bool) {
        if isLog {
            print(items, separator: separator, terminator: terminator)
        }
    }
}
