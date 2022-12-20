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
            thumbView.image = nil
            if let url = URL(string: movie?.images.first ?? "") {
                // This is for demo purpose because the function ImageLoader.shared.loadValue itself will return cache image if exist
//                if let image = ImageCache.shared.cacheImage(for: url, preferredSize: thumbView.frame.size) {
//                    print("[Movie Cell] Get from cache directly")
//                    thumbView.image = image
//                    return
//                }
                
                print("[Movie Cell] Start load image")
                ImageCache.shared.loadImage(from: url, preferredSize: thumbView.frame.size) { [weak self] result, resultUrl in
                    guard let self = self else {
                        return
                    }
                    
                    switch result {
                    case let .success(image):
                        print("[Movie Cell] Finish load image: \(image) - \(self)")
                        // Because for tableviewcell or collectionviewcell: we are reusing cell, so sometimes the callback's result will NOT be belong to this cell anymore
                        // ===> This checking to make sure this callback's result is belong to this current cell
                        if resultUrl.absoluteString == self.movie?.images.first {
                            self.thumbView.image = image
                        } else {
                            print("[Movie Cell] Ignore because different url")
                        }
                    case .failure:
                        if resultUrl.absoluteString == self.movie?.images.first {
                            self.thumbView.image = nil
                        } else {
                            print("[Movie Cell] Ignore because different url (error)")
                        }
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
