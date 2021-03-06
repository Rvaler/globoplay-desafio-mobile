//
//  APIClient.swift
//  My Movies
//
//  Created by Rafael Valer on 10/08/20.
//  Copyright © 2020 Rafael Valer. All rights reserved.
//

import Foundation

final class APIClient {
    
    let manager: APIManager
    
    init(manager: APIManager) {
        self.manager = manager
    }
    
    /// Gets the movie details
    /// - Parameters:
    ///   - movieId: Movie ID
    ///   - completion: Closure with request completion
    func getMovieDetails(_ movieId: String, completion: @escaping (MovieDetailsResponse) -> Void) {
        manager.request(endPoint: .getMovieDetails(movieId)) { (response) in
            switch response {
            case .sucess(let data):
                completion(MovieDetailsResponse.parse(data)); break
            case .error(let appError):
                completion(MovieDetailsResponse.failed(error: appError)); break
            }
        }
    }
    
    /// Gets movies based on query params
    /// - Parameters:
    ///   - page: Page number
    ///   - genre: Movie genre
    ///   - completion: Closure with request completion
    func discoverMovies(onPage page: Int,
                        withGenre genre: Int? = nil,
                        completion: @escaping (MoviesResponse) -> Void) {
        manager.request(endPoint: .discoverMovies(page, genre)) { (response) in
            switch response {
            case .sucess(let data):
                completion(MoviesResponse.parse(data)); break
            case .error(let appError):
                completion(MoviesResponse.failed(error: appError)); break
            }
        }
    }
    
    
    /// Gets movies recommendations based on a specific movie
    /// - Parameters:
    ///   - movieId: Movie ID
    ///   - completion: Closure with request completion
    func getMovieRecomendations(_ movieId: String, completion: @escaping (MoviesResponse) -> Void) {
        
        manager.request(endPoint: .getMovieRecommendations(movieId)) { (response) in
            switch response {
            case .sucess(let data):
                completion(MoviesResponse.parse(data)); break
            case .error(let error):
                completion(MoviesResponse.failed(error: error)); break
            }
        }
    }
    
    
    /// Gets movie videos based on a specific movie
    /// - Parameters:
    ///   - movieId: Movie ID
    ///   - completion: Closure with request completion
    func getMovieTrailer(_ movieId: String, completion: @escaping (VideosResponse) -> Void) {
     
        manager.request(endPoint: .getMovieTrailer(movieId)) { (response) in
            switch response{
            case .sucess(let data):
                completion(VideosResponse.parse(data)); break
            case .error(let error):
                completion(.failed(error: error)); break
            }
        }
    }
    
    /// Gets movie videos based on a specific query text
    /// - Parameters:
    ///   - queryString: Quey text String
    ///   - completion: Closure with request completion
    func getSearchMovies(_ queryString: String, completion: @escaping (MoviesResponse) -> Void) {
        
        manager.request(endPoint: .getSearchMovies(queryString)) { (response) in
            switch response {
            case .sucess(let data):
                completion(MoviesResponse.parse(data)); break
            case .error(let error):
                completion(.failed(error: error)); break
            }
        }
    }
}
