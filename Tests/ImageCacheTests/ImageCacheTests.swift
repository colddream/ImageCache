import XCTest
@testable import ImageCache

final class ImageCacheTests: XCTestCase {
    var imageCache: ImageCache!
    
    override func setUpWithError() throws {
        imageCache = try ImageCache(config: .init(type: .both(memory: .init(countLimit: 100, totalCostLimit: 100 * 1024 * 1024),
                                                              disk: .init(name: "ImageCacheTests_ImageCache", sizeLimit: 0)),
                                                  clearCacheType: .both))
    }
    
    override func tearDownWithError() throws {
        try imageCache.removeCache()
        imageCache = nil
    }
}


// MARK: - Cache

extension ImageCacheTests {
    func testImageLoader() throws {
        let waitExpectation = expectation(description: "Waiting")
        
        self.loadImages {
            waitExpectation.fulfill()
        }
        
        waitForExpectations(timeout: 5)
    }
    
    func testImageLoaderRaceCondition() throws {
        let waitExpectation = expectation(description: "Waiting")
        
        let concurrentQueue = DispatchQueue(label: "Testing", attributes: .concurrent)
        
        let maxBlockCount = 100
        
        for i in 0..<maxBlockCount {
            concurrentQueue.async {
                self.loadImages {
                    if i == maxBlockCount - 1 {
                        waitExpectation.fulfill()
                    }
                }
            }
        }
        
        waitForExpectations(timeout: 80)
    }
    
    func testImageLoaderDeadLock() {
        let waitExpectation = expectation(description: "Waiting")
        let imageUrls = [
            "https://res.cloudinary.com/demo/basketball_shot.jpg",
            "https://res.cloudinary.com/demo/basketball_shot.jpg",
            "https://live.staticflickr.com/2912/13981352255_fc59cfdba2_b.jpg",
        ]
        let imageUrls2 = [
            "https://live.staticflickr.com/2912/13981352255_fc59cfdba2_b.jpg",
            "https://res.cloudinary.com/demo/image/upload/if_ar_gt_3:4_and_w_gt_300_and_h_gt_200,c_crop,w_300,h_200/sample.jpg"
        ]
        
        self.loadImages(imageUrls: imageUrls) {
            self.loadImages(imageUrls: imageUrls2) {
                waitExpectation.fulfill()
            }
        }
        
        waitForExpectations(timeout: 80)
    }
}

// MARK: - Helper methods

extension ImageCacheTests {
    private func loadImages(completion: @escaping () -> Void) {
        let imageUrls = [
            "https://res.cloudinary.com/demo/basketball_shot.jpg",
            "https://res.cloudinary.com/demo/basketball_shot.jpg",
            "https://live.staticflickr.com/2912/13981352255_fc59cfdba2_b.jpg",
            "https://res.cloudinary.com/demo/image/upload/if_ar_gt_3:4_and_w_gt_300_and_h_gt_200,c_crop,w_300,h_200/sample.jpg"
        ]
        loadImages(imageUrls: imageUrls, completion: completion)
    }
    
    private func loadImages(imageUrls: [String], completion: @escaping () -> Void) {
        var finishedCount = 0
        for urlString in imageUrls {
            imageCache.loadImage(from: URL(string: urlString)!) { result, resultUrl in
                print("Finished Load for: \(urlString)")
                switch result {
                case .success(let image):
                    print("\(image)")
                case .failure(let error):
                    print("\(error.localizedDescription)")
                }
                
                finishedCount += 1
                
                // Last url
                if finishedCount == imageUrls.count {
                    completion()
                }
            }
        }
    }
}
