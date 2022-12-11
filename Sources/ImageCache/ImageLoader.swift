//
//  ImageLoader.swift
//  ImageCache
//
//  Created by Do Thang on 08/12/2022.
//

import UIKit
import Cache

public class ImageLoader: NSObject {
    public static let shared = ImageLoader(cache: Cache<URL, UIImage>(config: .init(countLimit: 100, memoryLimit: 50 * 1024 * 1024)),
                                           executeQueue: OperationQueue(),
                                           receiveQueue: .main)
    
    private var cache: any Cacheable<URL, UIImage>
    private var executeQueue: OperationQueue
    private var receiveQueue: OperationQueue
    private var session: URLSession
    
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
    
    // Load image
    public func loadImage(from url: URL,
                          isLog: Bool = false,
                          completion: @escaping (Result<UIImage, Error>) -> Void) {
        if let image = cache[url] {
            if isLog {
                print("[ImageLoader] image from cache (\(url.absoluteString))")
            }
            completion(.success(image))
            return
        }
        
        if isLog {
            print("[ImageLoader] Start get image from server (\(url.absoluteString))")
        }
        let operation = DataTaskOperation(session: session, url: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            if let data = data,
                let image = UIImage(data: data) {
                self.cache[url] = image
                
                if isLog {
                    print("[ImageLoader] image from server (\(url.absoluteString))")
                }
                completion(.success(image))
                return
            }

            let error = CustomError(message: "Invalid Image Data")
            completion(.failure(error))
        }
        executeQueue.addOperation(operation)
    }
    
    public func removeCache() {
        self.cache.removeAll()
    }
}
