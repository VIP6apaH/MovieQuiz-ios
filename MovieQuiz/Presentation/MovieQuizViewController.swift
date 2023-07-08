import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.layer.cornerRadius = 20
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        presenter.statisticService = StatisticServiceImplementation()
        showingAlert = AlertPresenter(alertDelegate: self)
        showLoadingIndicator()
        questionFactory?.loadData()
        presenter.viewController = self
    }
    // MARK: - QuestionFactoryDelegate
    
    
    // MARK: - IBOutlet
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet weak var noButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var yesButtom: UIButton!
    // MARK: - IBAction
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        presenter.yesButtonClicked()
    }
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        presenter.noButtonClicked()
    }
    // MARK: - private func
    
    func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
        
    }
    
    func showAnswerResult(isCorrect: Bool) {
        if isCorrect {
            presenter.correctAnswers += 1
        }
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        self.yesButtom.isEnabled = false
        self.noButton.isEnabled = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                    guard let self = self else { return }
                    self.presenter.correctAnswers = self.correctAnswers
                    self.presenter.questionFactory = self.questionFactory
                    self.presenter.showNextQuestionOrResults()
                    self.yesButtom.isEnabled = true
                    self.noButton.isEnabled = true
                    self.imageView.layer.borderColor = UIColor.clear.cgColor
        }
    }
    
    
    func didRecieveNextQuestion(question: QuizQuestion?) {
           presenter.didRecieveNextQuestion(question: question)
       }

    
    func didLoadDataFromServer() {
        activityIndicator.isHidden = true // скрываем индикатор загрузки
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) {
        showNetworkError(message: error.localizedDescription) // возьмём в качестве сообщения описание ошибки
    }
    
    
    private func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    private func hideLoadingIndicator() {
        activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
    }
    
    private func showNetworkError(message: String) {
        hideLoadingIndicator()
        
        let model = AlertModel(title: "Ошибка",
                               text: message,
                               buttonText: "Попробовать еще раз", completion: { [weak self] _ in
            guard let self = self else { return }
            
            self.presenter.resetQuestionIndex()
            self.presenter.correctAnswers = 0
            
            self.questionFactory?.requestNextQuestion()
        })
        
        showingAlert?.showAlert(alertModel: model)
    }
    
    
    
    // MARK: - private var
    private var correctAnswers = 0
 //   private var currentQuestion: QuizQuestion?
    private var questionFactory: QuestionFactoryProtocol?
    private var showingAlert: AlertPresenter?
 //   private var statisticService: StatisticService?
    // MARK: - private let
    private let presenter = MovieQuizPresenter()
}
