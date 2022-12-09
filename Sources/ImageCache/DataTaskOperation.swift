//
//  DataTaskOperation.swift
//  ImageCache
//
//  Created by Do Thang on 08/12/2022.
//

import Foundation

class DataTaskOperation: Operation {
    // MARK: - Predefine
    enum State {
        case ready
        case executing
        case finished
    }
    
    private var task : URLSessionDataTask!
    private var state: State = .ready {
        willSet {
            self.willChangeValue(forKey: "isExecuting")
            self.willChangeValue(forKey: "isFinished")
        }
        didSet {
            self.didChangeValue(forKey: "isExecuting")
            self.didChangeValue(forKey: "isFinished")
        }
    }
    
    // MARK: - Override Properties
    
    override var isReady: Bool { return state == .ready }
    override var isExecuting: Bool { return state == .executing }
    override var isFinished: Bool { return state == .finished }
    
    // MARK: - Init
    
    init(session: URLSession, url: URL, completionHandler: ((Data?, URLResponse?, Error?) -> Void)?) {
        super.init()
        
        // use weak self to prevent retain cycle
        task = session.dataTask(with: url, completionHandler: { [weak self] data, response, error in
            completionHandler?(data, response, error)
            self?.state = .finished
        })
    }
    
    // MARK: - Override methods
    
    override func start() {
        // At no time in your start method should you ever call super (https://developer.apple.com/documentation/foundation/nsoperation?language=objc#1661262)
        super.start()
        
        /*
         if the operation or queue got cancelled even
         before the operation has started, set the
         operation state to finished and return
         */
        // Your start method should also check to see if the operation itself was cancelled before actually starting the task (https://developer.apple.com/documentation/foundation/nsoperation?language=objc#1661262)
        if self.isCancelled {
            state = .finished
            return
        }
        
        // set the state to executing
        state = .executing
        
        // start get data
        self.task.resume()
    }
    
    override func cancel() {
        super.cancel()
        
        // cancel the data task
        self.task.cancel()
    }
}
