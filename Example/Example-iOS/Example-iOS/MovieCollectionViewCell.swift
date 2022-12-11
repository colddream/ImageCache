//
//  MovieCollectionViewCell.swift
//  Example-iOS
//
//  Created by Do Thang on 10/12/2022.
//

import UIKit
import ImageCache

class MovieCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var thumbView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    var movie: Movie? {
        didSet {
            titleLabel.text = movie?.title
            if let url = URL(string: movie?.images.first ?? "") {
                ImageLoader.shared.loadImage(from: url, isLog: true) { result in
                    switch result {
                    case let .success(image):
                        self.thumbView.image = image
                    case .failure:
                        self.thumbView.image = nil
                    }
                }
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}