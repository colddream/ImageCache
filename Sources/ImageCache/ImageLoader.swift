//
//  ImageLoader.swift
//  ImageCache
//
//  Created by Do Thang on 08/12/2022.
//

import UIKit

public class ImageLoader: NSObject {
    public static let shared = ImageLoader(cache: ImageCache(), executeQueue: OperationQueue(), receiveQueue: .main)
    
    private var cache: ImageCacheType
    private var executeQueue: OperationQueue
    private var receiveQueue: OperationQueue
    private var session: URLSession
    
    // Init
    public init(cache: ImageCacheType,
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
    public func config(cache: ImageCacheType,
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
                          completion: @escaping (Result<UIImage, Error>) -> Void) {
        if let image = cache[url] {
            completion(.success(image))
            return
        }
        
        let operation = DataTaskOperation(session: session, url: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            if let data = data,
                let image = UIImage(data: data) {
                completion(.success(image))
                return
            }

            let error = CustomError(message: "Invalid Image Data")
            completion(.failure(error))
        }
        executeQueue.addOperation(operation)
    }
    
    public func removeCache() {
        self.cache.removeCache()
    }
}
