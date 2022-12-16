//
//  OptimizedImageLoader.swift
//  ImageCache
//
//  Created by Do Thang on 16/12/2022.
//

import UIKit
import Cache

public class OptimizedImageLoader: BaseLoader<String, UIImage> {
    public static let shared = OptimizedImageLoader(cache: Cache<String, UIImage>(config: .init(countLimit: 50, memoryLimit: 50 * 1024 * 1024)),
                                                    executeQueue: OptimizedImageLoader.defaultExecuteQueue(),
                                                    receiveQueue: .main)
    
    public override func value(from data: Data) -> UIImage? {
        let image = ImageIOHelper.downsample(imageFrom: data, to: CGSize(width: 90, height: 120))
        // let image = UIImage(data: data)
        return image
    }
    
    private static func defaultExecuteQueue() -> OperationQueue {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 6
        return queue
    }
}
