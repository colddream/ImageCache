//
//  CacheLoader.swift
//  ImageCache
//
//  Created by Do Thang on 14/12/2022.
//

import UIKit
import Cache

public protocol CacheLoader: AnyObject {
    associatedtype Value
    typealias Handler = (Result<Value, Error>, URL) -> Void
    
    var cache: any Cacheable<URL, Value> { get set }
    var executeQueue: OperationQueue { get set }
    var receiveQueue: OperationQueue { get set }
    var session: URLSession { get set }
    
    var loadingUrls: [URL: Bool] { get set }
    var pendingHandlers: [URL: [Handler]] { get set }
    
    func value(from data: Data) -> Value?
}

extension CacheLoader {
    public static func regenerateSession(receiveQueue: OperationQueue) -> URLSession {
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config, delegate: nil, delegateQueue: receiveQueue)
        return session
    }
}

// MARK: - public methods

extension CacheLoader {
    public func config(cache: any Cacheable<URL, Value>,
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
    
    /// Load value from cache (or from server)
    /// - Parameters:
    ///   - url: url to load value
    ///   - keepOnlyLatestHandler: true => just keep the latest handler for pendingHandlers, otherwise keep all handlers
    ///   - isLog: log or not
    ///   - completion: handler
    public func loadValue(from url: URL,
                          keepOnlyLatestHandler: Bool = false,
                          isLog: Bool = false,
                          completion: @escaping Handler) {
        if let value = cache[url] {
            logPrint("[CacheLoader] value from cache (\(url.absoluteString))", isLog: isLog)
            completion(.success(value), url)
            return
        }
        
        // Check if url is already loading
        if loadingUrls[url] == true {
            logPrint("[CacheLoader] waiting previous loading value", isLog: isLog)
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
        logPrint("[CacheLoader] Start get value from server (\(url.absoluteString))", isLog: isLog)
        let operation = DataTaskOperation(session: session, url: url) { [weak self] data, response, error in
            guard let self = self else {
                return
            }
            
            let result: Result<Value, Error>
            
            if let error = error {
                result = .failure(error)
                
            } else if let data = data, let value = self.value(from: data) {
                self.cache[url] = value
                self.logPrint("[CacheLoader] value from server (\(url.absoluteString))", isLog: isLog)
                result = .success(value)
                
            } else {
                let error = CustomError(message: "Invalid Value Data")
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
    
    /// Remove all cache values
    public func removeCache() {
        self.cache.removeAll()
    }
}

// MARK: - Helper methods

extension CacheLoader {
    private func handleResult(_ result: Result<Value, Error>, for url: URL) {
        if let handlers = pendingHandlers[url] {
            pendingHandlers[url] = nil
            handlers.forEach { $0(result, url) }
        }
        loadingUrls[url] = nil
    }
    
    private func logPrint(_ items: Any..., separator: String = " ", terminator: String = "\n", isLog: Bool) {
        if isLog {
            print(items, separator: separator, terminator: terminator)
        }
    }
}
