//
//  ImageLoader.swift
//  ImageCache
//
//  Created by Do Thang on 08/12/2022.
//

import UIKit

public class ImageLoader: NSObject {
    public static let shared = ImageLoader(cache: ImageCache(), executeQueue: OperationQueue(), receiveQueue: .main)
    
    private let cache: ImageCacheType
    private let executeQueue: OperationQueue
    private let receiveQueue: OperationQueue
    private lazy var session: URLSession = {
        let config = URLSessionConfiguration.default
        let sess = URLSession(configuration: config, delegate: nil, delegateQueue: receiveQueue)
        return sess
    }()
    
    // Init
    public init(cache: ImageCacheType,
                executeQueue: OperationQueue,
                receiveQueue: OperationQueue = .main) {
        self.cache = cache
        self.executeQueue = executeQueue
        self.receiveQueue = receiveQueue
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
}
