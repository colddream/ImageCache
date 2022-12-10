//
//  Movie.swift
//  Example-iOS
//
//  Created by Do Thang on 09/12/2022.
//

import Foundation

struct Movie: Codable {
    let title: String
    let images: [String]

    enum CodingKeys: String, CodingKey {
        case title = "Title"
        case images = "Images"
    }
}
