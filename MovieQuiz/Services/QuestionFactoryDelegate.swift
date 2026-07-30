//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by Magomed on 28.07.2026.
//

import Foundation

protocol QuestionFactoryDelegate: AnyObject {
    func didReceiveNextQuestion(question: QuizQuestion?)
}
