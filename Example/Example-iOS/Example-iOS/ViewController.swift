//
//  ViewController.swift
//  Example-iOS
//
//  Created by Do Thang on 09/12/2022.
//

import UIKit
import ImageCache

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupImageCache()
        testing()
    }

    private func setupImageCache() {
        let taskQueue = OperationQueue()
        taskQueue.maxConcurrentOperationCount = 1
        let config = ImageCache.Config(countLimit: 100, memoryLimit: 100 * 1024 * 1024)
        
        ImageLoader.shared.config(cache: ImageCache(config: config),
                                  executeQueue: taskQueue,
                                  receiveQueue: .main)
    }
    
    private func testing() {
        let imageUrls = [
//            "https://api.github.com/users/hadley/repos",
//            "http://ip-api.com/json",
            "https://api.github.com/repositories/19438/commits",
            "https://res.cloudinary.com/demo/basketball_shot.jpg",
            "https://live.staticflickr.com/2912/13981352255_fc59cfdba2_b.jpg",
            "https://res.cloudinary.com/demo/image/upload/if_ar_gt_3:4_and_w_gt_300_and_h_gt_200,c_crop,w_300,h_200/sample.jpg"
        ]
        
        var finishedCount = 0
        for urlString in imageUrls {
            ImageLoader.shared.loadImage(from: URL(string: urlString)!) { result in
                print("Finished Load for: \(urlString)")
                switch result {
                case .success(let image):
                    print("\(image)")
                case .failure(let error):
                    print("\(error.localizedDescription)")
                }
                
                finishedCount += 1
            }
        }
    }
}

