import Foundation
import UIKit

final class MovieQuizPresenter {
    let questionsAmount: Int = 10
    private var currentQuestionIndex: Int = 0
    
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    func resetQuestionIndex() {
        currentQuestionIndex = 0
    }
    
    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    func convert(model: QuizQuestion) -> QuizStepViewModel {
          return QuizStepViewModel(
              image: UIImage(data: model.image) ?? UIImage(),
              question: model.text,
              questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
      }
    func yesButtonClicked() {
            didAnswer(isYes: true)
        }
        
        func noButtonClicked() {
            didAnswer(isYes: false)
        }
        
        private func didAnswer(isYes: Bool) {
            guard let currentQuestion = currentQuestion else {
                return
            }
            
            let givenAnswer = isYes

            
            viewController?.showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
        }
    
    func didRecieveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quiz: viewModel)
        }
    }
    
    
     func showNextQuestionOrResults() {
        if isLastQuestion() {
            
            var text = "Ваш результат: \(correctAnswers)\\\(questionsAmount)"
            if let statisticService = statisticService {
                statisticService.store(correct: correctAnswers, total: questionsAmount)
                text += """
                \nКоличество сыгранных квизов: \(statisticService.gamesCount)
                Рекорд: \(statisticService.bestGame.correct)/\(statisticService.bestGame.total) (\(statisticService.bestGame.date.dateTimeString))
                Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%
                """
                questionFactory?.resetUsedIndices()
            }
            let viewModel = AlertModel(title: "Этот раунд окончен!", text: text, buttonText: "Сыграть ещё раз", completion: { [weak self] _ in
                guard let self = self else { return }
                self.resetQuestionIndex()
                self.correctAnswers = 0
                self.questionFactory?.requestNextQuestion()
                
            })
            showingAlert?.showAlert(alertModel: viewModel)
        } else {
            self.switchToNextQuestion()
            questionFactory?.requestNextQuestion()
        }
    }
    var questionFactory: QuestionFactoryProtocol?
    var statisticService: StatisticService?
    var correctAnswers = 0
    var currentQuestion: QuizQuestion?
    var showingAlert: AlertPresenter?
    weak var viewController: MovieQuizViewController?
} 
