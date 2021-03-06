//
//  MovieDetailsViewController.swift
//  My Movies
//
//  Created by Rafael Valer on 11/08/20.
//  Copyright © 2020 Rafael Valer. All rights reserved.
//

import UIKit
import WebKit

protocol MovieDetailsDisplayLogic: class {
    func displayFetchedMovieDetails(viewModel: MovieDetailsModels.FetchMovieDetails.ViewModel)
    func displayFetchedMovieRecommendations(viewModel: MovieDetailsModels.FetchMovieRecommendations.ViewModel)
    func displayFavoriteButton(withImage image: UIImage?, text: String)
    func displayTrailer(withURL url: URL)
    func displayErrorAlert(withTitle title: String, message: String, isTerminal: Bool)
}

class MovieDetailsViewController: UIViewController {
    
    static let identifier: String = "MovieDetailsViewController"
    
    var movieId: Int
    var interactor: MovieDetailsBusinessLogic?
    var router: (NSObject & MovieDetailsRoutingLogic & MovieDetailsDataPassing)?

    // MARK: Object lifecycle
    
    init?(coder: NSCoder, movieId: Int) {
        self.movieId = movieId
        super.init(coder: coder)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("You must create this view controller with a Movie")
    }
    
    // MARK: Setup
    
    private func setup() {
        let viewController = self
        let interactor = MovieDetailsInteractor()
        let presenter = MovieDetailsPresenter()
        let router = MovieDetailsRouter()
        viewController.interactor = interactor
        viewController.router = router
        interactor.presenter = presenter
        presenter.viewController = viewController
        router.viewController = viewController
        router.dataStore = interactor
    }
    
    // MARK: View lifecycle
    
    @IBOutlet weak var topBarView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var watchButton: UIButton!
    @IBOutlet weak var contentStackView: UIStackView!
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var movieDetailsButton: UIButton!
    @IBOutlet weak var movieDetailsUnderlineView: UIView!
    @IBOutlet weak var recommendationsButton: UIButton!
    @IBOutlet weak var recommendationsUnderlineView: UIView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var webView: WKWebView!
    
    var moviesCollectionView: MoviesCollectionView!
    var movieDetailsView: MovieDetailsView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        fetchMovieDetails()
        fetchMovieRecommendations()
    }
    
    private func setupView() {
        webView.navigationDelegate = self
        scrollView.delegate = self
        topBarView.alpha = 0
        
        moviesCollectionView = MoviesCollectionView()
        contentStackView.addArrangedSubview(moviesCollectionView)
        
        movieDetailsView = MovieDetailsView()
        movieDetailsView.isHidden = true
        movieDetailsUnderlineView.isHidden = true
        moviesCollectionView.delegate = self
        contentStackView.addArrangedSubview(movieDetailsView)
        
        favoriteButton.setImage(UIImage(named: "baseline-star_rate")?.withTintColor(.white), for: .normal)
        
        // hides back button for the first view controller of navigation stack
        backButton.isHidden = navigationController?.viewControllers.count ?? 0 <= 1
    }
    
    private func fetchMovieDetails() {
        view.displayAnimatedActivityIndicatorView()
        interactor?.fetchMovieDetails(movieId)
        interactor?.checkIfMovieIsFavorite(movieId)
    }
    
    private func fetchMovieRecommendations() {
        interactor?.fetchMovieRecommendations(movieId)
    }
    
    // MARK: - Actions
    
    @IBAction func watchButtonTouched(_ sender: Any) {
        displayAnimatedActivityIndicatorView()
        interactor?.fetchMovieTrailer(movieId)
    }
    
    @IBAction func favoriteButtonTouched(_ sender: Any) {
        interactor?.addOrRemoveMovieFromFavorites(movieId)
    }
    
    @IBAction func recommendationsButtonTouched(_ sender: Any) {
        movieDetailsView.isHidden = true
        moviesCollectionView.isHidden = false
        recommendationsButton.setTitleColor(.white, for: .normal)
        movieDetailsButton.setTitleColor(.darkGray, for: .normal)
        movieDetailsUnderlineView.isHidden = true
        recommendationsUnderlineView.isHidden = false
    }
    
    @IBAction func detailsButtonTouched(_ sender: Any) {
        movieDetailsView.isHidden = false
        moviesCollectionView.isHidden = true
        movieDetailsButton.setTitleColor(.white, for: .normal)
        recommendationsButton.setTitleColor(.darkGray, for: .normal)
        movieDetailsUnderlineView.isHidden = false
        recommendationsUnderlineView.isHidden = true
    }
    
    @IBAction func backButtonTouched(_ sender: Any) {
        self.router?.navigateToPreviousView()
    }
    
    @IBAction func closeButtonTouched(_ sender: Any) {
        router?.dismiss()
    }
}

// MARK: - MovieDetailsDisplayLogic
extension MovieDetailsViewController: MovieDetailsDisplayLogic {
    
    func displayFavoriteButton(withImage image: UIImage?, text: String) {
        favoriteButton.setTitle(text, for: .normal)
        favoriteButton.setImage(image, for: .normal)
    }
    
    func displayFetchedMovieRecommendations(viewModel: MovieDetailsModels.FetchMovieRecommendations.ViewModel) {
        
        let displayedMovies = viewModel.displayedMovies
        moviesCollectionView.setMovies(displayedMovies)
    }
    
    func displayFetchedMovieDetails(viewModel: MovieDetailsModels.FetchMovieDetails.ViewModel) {
        
        let displayedMovie = viewModel.displayedMovie
        movieDetailsView.setMovieDetails(displayedMovie)
        
        DispatchQueue.main.async { [weak self] in
            
            self?.view.hideAnimatedActivityIndicatorView()
            self?.titleLabel.text = displayedMovie.title
            self?.subtitleLabel.text = displayedMovie.type
            self?.descriptionLabel.text = displayedMovie.overview
            
            if let posterPath = displayedMovie.posterPath, let url = URL(string: posterPath) {
                self?.posterImageView.kf.setImage(with: url)
            }
            
            if let backdropPath = displayedMovie.backdropPath, let url = URL(string: backdropPath) {
                self?.backgroundImageView.kf.setImage(with: url)
            }
        }
    }

    
    func displayTrailer(withURL url: URL) {
        DispatchQueue.main.async { [weak self] in
            self?.webView.load(URLRequest(url: url))
        }
    }
    
    func displayErrorAlert(withTitle title: String, message: String, isTerminal: Bool) {
        DispatchQueue.main.async { [weak self] in
            self?.hideAnimatedActivityIndicatorView()
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let handler: (UIAlertAction) -> Void = { _ in
                self?.router?.dismiss()
            }
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: isTerminal ? handler : nil))
            self?.present(alert, animated: true, completion: nil)
        }
    }
}

// MARK: - 
extension MovieDetailsViewController: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        self.hideAnimatedActivityIndicatorView()
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        self.hideAnimatedActivityIndicatorView()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.hideAnimatedActivityIndicatorView()
    }
}

extension MovieDetailsViewController: MoviesCollectionViewDelegate {
    func didSelectItem(at indexPath: IndexPath) {
        router?.navigateToMovieDetails(atIndexPath: indexPath)
    }
}

extension MovieDetailsViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        topBarView.alpha = scrollView.contentOffset.y / 100
    }
}
