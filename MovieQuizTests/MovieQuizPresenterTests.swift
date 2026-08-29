//
//  MovieQuizPresenterTests.swift
//  MovieQuizTests
//
//  Created by Magomed on 27.08.2026.
//

import XCTest
@testable import MovieQuiz

final class QuestionFactoryDummy: QuestionFactoryProtocol {
    func requestNextQuestion() {
        
    }
    
    func loadData() {
        
    }
}

final class MovieQuizViewControllerMock: MovieQuizViewControllerProtocol {
    
    func show(quiz step: QuizStepViewModel) {
        
    }
    
    func show(quiz result: QuizResultsViewModel) {
        
    }
    
    func highlightImageBorder(isCorrectAnswer: Bool) {
        
    }
    
    func showLoadingIndicator() {
        
    }
    
    func hideLoadingIndicator() {
        
    }
    
    func showNetworkError(message: String) {
        
    }
}

final class MovieQuizPresenterTests: XCTestCase {
    func testPresenterConvertModel() throws {
        // Given
        let viewControllerMock = MovieQuizViewControllerMock()
        let statisticService = StatisticService()
        let questionFactoryCreator: (QuestionFactoryDelegate) -> QuestionFactoryProtocol = { _ in
            QuestionFactoryDummy()
        }
        
        let sut = MovieQuizPresenter(viewController: viewControllerMock,
                                     statisticService: statisticService,
                                     questionFactoryCreator: questionFactoryCreator)
        let emptyData = Data()
        let question = QuizQuestion(imageName: emptyData, text: "Question Text", correctAnswer: true)
        // When
        let viewModel = sut.convert(model: question)
        // Then
        XCTAssertEqual(viewModel.imageName, emptyData)
        XCTAssertEqual(viewModel.question, "Question Text")
        XCTAssertEqual(viewModel.questionNumber, "1/10")
    }
}
