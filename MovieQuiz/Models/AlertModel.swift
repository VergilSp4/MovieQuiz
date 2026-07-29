//
//  AlertModel.swift
//  MovieQuiz
//
//  Created by Magomed on 28.07.2026.
//

import Foundation

struct AlertModel {
    let title: String
    let message: String
    let buttonText: String
    let completion: () -> Void
}
