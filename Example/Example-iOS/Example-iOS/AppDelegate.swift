//
//  AppDelegate.swift
//  Example-iOS
//
//  Created by Do Thang on 09/12/2022.
//

import UIKit
import ImageCache

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // Setup ImageCache
        setupImageCache()
        
        return true
    }
    
    private func setupImageCache() {
        try! ImageCache.shared.setup(config: .init(type: .both(memory: .init(countLimit: 100, totalCostLimit: 100 * 1024 * 1024),
                                                          disk: .init(name: "ImageCache.PreSetup", sizeLimit: 0)),
                                                   clearCacheType: .memoryOnly,
                                                   showLog: true))
    }
}
