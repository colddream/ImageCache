//
//  ViewController.swift
//  Example-iOS
//
//  Created by Do Thang on 09/12/2022.
//

import UIKit
import ImageCache

class ViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    private var movies: [Movie] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
        loadMovies()
    }
}

// MARK: - Helper methods

extension ViewController {
    private func configUI() {
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func loadMovies() {
        let moviesUrl = Bundle.main.url(forResource: "Movies2", withExtension: "json")!
        let data = try! Data(contentsOf: moviesUrl)
        let movies = try! JSONDecoder().decode([Movie].self, from: data)
        
        print("Load movies.count: \(movies.count)")
        
        self.movies = movies
        tableView.reloadData()
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath) as! MovieCell
        
        cell.movie = movies[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 160
    }
}
