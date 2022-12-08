//
//  ImageLoader.swift
//  ImageCache
//
//  Created by Do Thang on 08/12/2022.
//

import UIKit

public class ImageLoader {
    public static let shared = ImageLoader(cache: ImageCache())
    
    private let cache: ImageCacheType
    private lazy var backgroundQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 5
        return queue
    }()
    
    public init(cache: ImageCacheType) {
        self.cache = cache
    }
    
    public func loadImage(from url: URL,
                          completion: @escaping (Result<UIImage, Error>) -> Void) {
        if let image = cache[url] {
            completion(.success(image))
            return
        }
        
        let task = URLSession.shared.dataTask(with: URLRequest(url: url)) { data, response, error in
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
        task.resume()
    }
}
