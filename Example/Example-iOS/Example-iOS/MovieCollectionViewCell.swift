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
                print("[Movie Cell] Start load image")
                ImageLoader.shared.loadImage(from: url, isLog: true) { [weak self] result in
                    guard let self = self else {
                        return
                    }
                    
                    switch result {
                    case let .success(image):
                        print("[Movie Cell] Finish load image: \(image) - \(self)")
                        self.thumbView.image = image
                    case .failure:
                        self.thumbView.image = nil
                    }
                }
            }
        }
    }
    
    deinit {
        print("Deinit MovieCollectionViewCell")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
