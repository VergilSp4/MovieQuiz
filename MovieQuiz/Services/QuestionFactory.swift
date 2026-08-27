//
//  QuestionFactory.swift
//  MovieQuiz
//
//  Created by Magomed on 28.07.2026.
//

import Foundation

final class QuestionFactory: QuestionFactoryProtocol {
    private let moviesLoader: MoviesLoading
    private weak var delegate: QuestionFactoryDelegate?
    private var movies: [MostPopularMovie] = []

    
    init(moviesLoader: MoviesLoading, delegate: QuestionFactoryDelegate?) {
        self.moviesLoader = moviesLoader
        self.delegate = delegate
    }
    
    func setup(delegate: QuestionFactoryDelegate) {
        self.delegate = delegate
    }
    
    func loadData() {
        moviesLoader.loadMovies { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case.success(let mostPopularMovies):
                    self.movies = mostPopularMovies.items
                    self.delegate?.didLoadDataFromServer()
                case .failure(let error):
                    self .delegate?.didFailToLoadData(with: error)
                }
            }
        }
    }
    
    func requestNextQuestion() {
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            let index = (0..<self.movies.count).randomElement() ?? 0
            
            guard let movie = self.movies[safe: index] else { return }
            
            var imageData = Data()
            
            do {
                imageData = try Data(contentsOf: movie.resizedImageURL)
                print("Image has been uploaded")
            } catch {
                print("Failed to load image")
            }
            
            let randomRating = Int.random(in: 6...8)
            let isMoreThan = Bool.random()
            
            let text = isMoreThan ? "Рейтинг этого фильма больше чем \(randomRating)?" : "Рейтинг этого фильма меньше чем \(randomRating)?"
            guard let movieRating = Float(movie.rating) else { return }
            let correctAnswer = isMoreThan ? movieRating > Float(randomRating) : movieRating < Float(randomRating)
            
            let question = QuizQuestion(imageName: imageData,
                                        text: text,
                                        correctAnswer: correctAnswer)
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.delegate?.didReceiveNextQuestion(question: question)
            }
        }
    }
}
