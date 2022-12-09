//
//  CustomError.swift
//  ImageCache
//
//  Created by Do Thang on 08/12/2022.
//

import Foundation

public struct CustomError: LocalizedError {
    let message: String
    
    public init(message: String) {
        self.message = message
    }
    
    public var errorDescription: String? {
        return [message.isEmpty ? nil : message, "Unknown Error."].compactMap { $0 }.first
    }
}
