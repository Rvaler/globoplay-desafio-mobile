//
//  MovieDetailsWorker.swift
//  My Movies
//
//  Created by Rafael Valer on 11/08/20.
//  Copyright © 2020 Rafael Valer. All rights reserved.
//

import Foundation

class MovieDetailsWorker {

    enum MovieDetailsResponse {
        case success(Movie)
        case error(Error)
    }
    
    enum MovieRecommendationsResponse {
        case success([Movie])
        case error(Error)
    }
    
    enum MovieTrailerResponse {
        case success(Video)
        case error(Error)
    }

    func fetchMovieDetails(request: MovieDetailsModels.FetchMovieDetails.Request,
                           completion: @escaping (MovieDetailsResponse) -> Void) {
        
        APIClient(manager: APIManager.shared).getMovieDetails(request.movieId) { (response) in
            
            switch response {
            case .success(movie: let movie):
                completion(.success(movie)); break
            case .failed(error: let error):
                completion(.error(error)); break
            }
        }
    }
    
    func fetchMovieRecommendations(request: MovieDetailsModels.FetchMovieRecommendations.Request,
                                   completion: @escaping (MovieRecommendationsResponse) -> Void) {
        
        APIClient(manager: APIManager.shared).getMovieRecomendations(request.movieId) { (response) in
            
            switch response {
            case .success(movies: let movies):
                completion(.success(movies)); break
            case .failed(error: let error):
                completion(.error(error)); break
            }
        }
    }
    
    func fetchMovieTrailer(request: MovieDetailsModels.FetchMovieTrailer.Request, completion: @escaping (MovieTrailerResponse) -> Void) {
        
        APIClient(manager: APIManager.shared).getMovieTrailer(request.movieId) { (response) in
            
            switch response {
            case .success(videos: let videos):
                
                var trailerVideo: Video?
                // filter results that match YouTube provider and Trailer type
                for video in videos {
                    if video.site == "YouTube" && video.type == "Trailer" {
                        trailerVideo = video; break
                    }
                }
                
                if let trailerVideo = trailerVideo {
                    completion(.success(trailerVideo)); break
                } else {
                    completion(.error(ApplicationError.missingData)); break
                }
            case .failed(error: let error):
                completion(.error(error)); break
            }
        }
    }
}
