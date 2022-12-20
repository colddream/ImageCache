//
//  OptimizedImageLoader.swift
//  ImageCache
//
//  Created by Do Thang on 16/12/2022.
//

import UIKit
import Cache

public class OptimizedImageLoader: BaseLoader<UIImage> {
    public static let shared = ImageLoader(cache: Cache(type: .cacheInfo(name: "OptimizedImageLoader.shared", cacheDirectoryUrl: nil), config: .init(clearCacheType: .both)),
                                           config: .init(showLog: false, keepOnlyLatestHandler: true),
                                           executeQueue: OptimizedImageLoader.defaultExecuteQueue(),
                                           receiveQueue: .main)
    
//    public override func value(from data: Data) -> UIImage? {
//        let image = ImageIOHelper.downsample(imageFrom: data, to: CGSize(width: 90, height: 120))
//        // let image = UIImage(data: data)
//        return image
//    }
    
    private static func defaultExecuteQueue() -> OperationQueue {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 6
        return queue
    }
}
