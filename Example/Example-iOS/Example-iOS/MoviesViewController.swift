//
//  MoviesViewController.swift
//  Example-iOS
//
//  Created by Do Thang on 10/12/2022.
//

import UIKit

class MoviesViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    
    private var movies: [Movie] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
        loadMovies()
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
        
        cell.movie = movies[indexPath.row]
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = UIScreen.main.bounds.width/3 - 40
        let height = width * 1.5
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
}
