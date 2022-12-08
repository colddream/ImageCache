import XCTest
@testable import ImageCache

final class ImageCacheTests: XCTestCase {
    var imageLoader: ImageLoader!
    
    override func setUpWithError() throws {
        imageLoader = ImageLoader(cache: ImageCache())
    }
    
    override func tearDownWithError() throws {
        imageLoader = nil
    }
    
    func testImageLoader() throws {
        let waitExpectation = expectation(description: "Waiting")
        
        let imageUrls = [
            "https://res.cloudinary.com/demo/basketball_shot.jpg",
            "https://res.cloudinary.com/demo/image/upload/if_ar_gt_3:4_and_w_gt_300_and_h_gt_200,c_crop,w_300,h_200/sample.jpg"
        ]
        
        var finishedCount = 0
        for urlString in imageUrls {
            imageLoader.loadImage(from: URL(string: urlString)!) { result in
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
                    waitExpectation.fulfill()
                }
            }
        }
        
        waitForExpectations(timeout: 5)
    }
}

extension XCTestCase {
    
//    func wait(for duration: TimeInterval) {
//        let waitExpectation = expectation(description: "Waiting")
//
//        let when = DispatchTime.now() + duration
//        DispatchQueue.main.asyncAfter(deadline: when) {
//            waitExpectation.fulfill()
//        }
//
//        // We use a buffer here to avoid flakiness with Timer on CI
//        waitForExpectations(timeout: duration + 0.5)
//    }
}
