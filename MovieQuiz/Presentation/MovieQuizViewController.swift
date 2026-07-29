import UIKit

final class MovieQuizViewController: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var noButton: UIButton!
    @IBOutlet weak var yesButton: UIButton!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var counterLabel: UILabel!

    // MARK: - Properties

    private var currentQuestionIndex = 0
    private var correctAnswers = 0
    private var isAnswerButtonsEnabled = true
    private let questionsAmount: Int = 10
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    private var alertPresenter = AlertPresenter()
    private var statisticService: StatisticServiceProtocol = StatisticService()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupQuestionFactory()
        
        yesButton.layer.cornerRadius = 15
        yesButton.clipsToBounds = true
    }

    // MARK: - Actions

    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        if isAnswerButtonsEnabled {
            checkAnswer(true)
        }
    }

    @IBAction private func noButtonClicked(_ sender: UIButton) {
        if isAnswerButtonsEnabled {
            checkAnswer(false)
        }
    }

    // MARK: - Setup

    private func setupQuestionFactory() {
        let questionFactory = QuestionFactory()
        questionFactory.delegate = self
        self.questionFactory = questionFactory
        self.questionFactory?.requestNextQuestion()
    }

    private func setupImageView() {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.cornerRadius = 20
    }

    // MARK: - Mapping

    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        QuizStepViewModel(
            imageName: UIImage(named: model.imageName) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)"
        )
    }

    // MARK: - Checking Answer

    private func checkAnswer(_ givenAnswer: Bool) {
        guard let currentQuestion else { return }

        showAnswerResult(
            isCorrect: currentQuestion.correctAnswer == givenAnswer
        )
    }

    // MARK: - Presentation

    private func show(quiz step: QuizStepViewModel) {
        setupImageView()
        imageView.image = step.imageName
        imageView.layer.borderColor = UIColor.clear.cgColor
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }

    private func show(quiz result: QuizResultsViewModel) {
        let alertModel = AlertModel(
            title: result.title,
            message: result.text,
            buttonText: result.buttonText
        ) { [weak self] in
            guard let self else { return }

            self.restartGame()
        }

        alertPresenter.show(in: self, model: alertModel)
    }

    // MARK: - Quiz Flow

    private func showAnswerResult(isCorrect: Bool) {
        if isCorrect {
            correctAnswers += 1
        }

        setupImageView()
        imageView.layer.borderColor =
            isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        isAnswerButtonsEnabled = false

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self else { return }
            self.showNextQuestionOrResults()
            self.isAnswerButtonsEnabled = true
        }
    }

    private func makeQuizResultText() -> String {
        "Ваш результат: \(correctAnswers)/\(questionsAmount)\nКоличество сыгранных квизов: \(statisticService.gamesCount)\nРекорд: \(statisticService.bestGame.correct)/\(statisticService.bestGame.total) (\(statisticService.bestGame.date.dateTimeString))\nСредняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%"
    }

    private func showNextQuestionOrResults() {
        if currentQuestionIndex == questionsAmount - 1 {
            statisticService.store(
                correct: correctAnswers,
                total: questionsAmount
            )

            let viewModel = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: makeQuizResultText(),
                buttonText: "Сыграть еще раз"
            )

            show(quiz: viewModel)
        } else {
            currentQuestionIndex += 1
            questionFactory?.requestNextQuestion()
        }
    }

    private func restartGame() {
        self.currentQuestionIndex = 0
        self.correctAnswers = 0
        self.questionFactory?.requestNextQuestion()
    }
}

// MARK: - QuestionFactoryDelegate

extension MovieQuizViewController: QuestionFactoryDelegate {

    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question else { return }

        currentQuestion = question
        let viewModel = convert(model: question)

        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }
}
