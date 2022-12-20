//
//  MoviesViewController.swift
//  Example-iOS
//
//  Created by Do Thang on 10/12/2022.
//

import UIKit
import ImageCache

class MoviesViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    
    private var movies: [Movie] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
        loadMovies()
    }
    
    deinit {
        print("Deinit MoviesViewController")
        ImageCache.shared.cancelAll()
    }
    
    @IBAction func pressTest(_ sender: Any) {
    }
    
    override func didReceiveMemoryWarning() {
        try? ImageCache.shared.removeCache()
        super.didReceiveMemoryWarning()
    }
}

// MARK: - Helper methods

extension MoviesViewController {
    private func configUI() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.contentInset = .init(top: 10, left: 10, bottom: 10, right: 10)
    }
    
    private func loadMovies() {
        let moviesUrl = Bundle.main.url(forResource: "Movies2", withExtension: "json")!
        let data = try! Data(contentsOf: moviesUrl)
        let movies = try! JSONDecoder().decode([Movie].self, from: data)
        
        print("Load movies.count: \(movies.count)")
        
        self.movies = movies
        collectionView.reloadData()
    }
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegateFlowLayout

extension MoviesViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return movies.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MovieCollectionViewCell", for: indexPath) as! MovieCollectionViewCell
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = UIScreen.main.bounds.width/3 - 40
        let height = width * 1.5
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        // print("willDisplay at \(indexPath)")
        // Assign cell.movie = here to make sure the movie only assign when the cell is really display
        // If assigning on the method cellForItemAt => movie will be assign even we didn't see it => cause loading a lot of image
        (cell as! MovieCollectionViewCell).movie = movies[indexPath.row]
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        // print("didEndDisplaying at \(indexPath)")
        let movie = movies[indexPath.row]
        if let url = URL(string: movie.images.first ?? "") {
            // When this cell is disappear => we should remove the pending handlers of the url of this cell to make sure the ImageLoader does NOT notify to the old pending handlers
            // We should only do this removing if each cell's url of the listview (tableview/collectionview) is unique
            ImageCache.shared.removePendingHandlers(for: url)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
}
