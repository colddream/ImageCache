import XCTest
@testable import ImageCache
import Cache

final class ImageCacheTests: XCTestCase {
    var imageLoader: ImageLoader!
    
    override func setUpWithError() throws {
        let taskQueue = OperationQueue()
        taskQueue.maxConcurrentOperationCount = 1
        
        imageLoader = ImageLoader.shared
        imageLoader.config(cache: Cache(config: .init(countLimit: 100, memoryLimit: 100 * 1024 * 1024)),
                           executeQueue: taskQueue,
                           receiveQueue:.main)
    }
    
    override func tearDownWithError() throws {
        imageLoader = nil
    }
    
    func testImageLoader() throws {
        let waitExpectation = expectation(description: "Waiting")
        
        let imageUrls = [
//            "https://api.github.com/users/hadley/repos",
//            "http://ip-api.com/json",
//            "https://api.github.com/repositories/19438/commits",
            "https://res.cloudinary.com/demo/basketball_shot.jpg",
            "https://res.cloudinary.com/demo/basketball_shot.jpg",
//            "https://live.staticflickr.com/2912/13981352255_fc59cfdba2_b.jpg",
//            "https://res.cloudinary.com/demo/image/upload/if_ar_gt_3:4_and_w_gt_300_and_h_gt_200,c_crop,w_300,h_200/sample.jpg"
        ]
        
        var finishedCount = 0
        for urlString in imageUrls {
            imageLoader.loadImage(from: URL(string: urlString)!, keepOnlyLatestHandler: false, isLog: true) { result, resultUrl in
                // print("Finished Load for: \(urlString)")
                switch result {
                case .success(let image):
                    print("\(image)")
                case .failure(let error):
                    print("\(error.localizedDescription)")
                }
                
                finishedCount += 1
                
                // Last url
                if finishedCount == imageUrls.count {
//                    try? self.testImageLoader()
                     waitExpectation.fulfill()
                }
            }
        }
        
        waitForExpectations(timeout: 80)
    }
}
