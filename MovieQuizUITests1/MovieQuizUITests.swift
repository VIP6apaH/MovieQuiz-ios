import XCTest


class MovieQuizUITests: XCTestCase {
    // swiftlint:disable:next implicitly_unwrapped_optional
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        app = XCUIApplication()
        app.launch()
        
        // это специальная настройка для тестов: если один тест не прошёл,
        // то следующие тесты запускаться не будут; и правда, зачем ждать?
        continueAfterFailure = false
    }
    override func tearDownWithError() throws {
        try super.tearDownWithError()
        
        app.terminate()
        app = nil
    }
    func testYesButton() {
        sleep(3)
        
        let firstPoster = app.images["Poster"]
        sleep(3)
        let firstPosterData = firstPoster.screenshot().pngRepresentation
        sleep(3)
        let indexLabel = app.staticTexts["Index"]
        sleep(3)
        app.buttons["Yes"].tap()
        sleep(3)
        
        XCTAssertEqual(indexLabel.label, "2/10")
        sleep(3)
        let secondPoster = app.images["Poster"]
        sleep(3)
        let secondPosterData = secondPoster.screenshot().pngRepresentation
        sleep(3)
        
        XCTAssertNotEqual(firstPosterData, secondPosterData)
    }
    
    func testNoButton() {
        sleep(3)
        
        let firstPoster = app.images["Poster"]
        sleep(3)
        let firstPosterData = firstPoster.screenshot().pngRepresentation
        sleep(3)
        let indexLabel = app.staticTexts["Index"]
        sleep(3)
        
        app.buttons["No"].tap()
        sleep(3)
        
        XCTAssertEqual(indexLabel.label, "2/10")
        sleep(3)
        let secondPoster = app.images["Poster"]
        sleep(3)
        let secondPosterData = secondPoster.screenshot().pngRepresentation
        sleep(3)
        
        XCTAssertNotEqual(firstPosterData, secondPosterData)
    }
    func testGameFinish() {
        sleep(2)
        for _ in 1...10 {
            app.buttons["No"].tap()
            sleep(2)
        }
        sleep(2)
        let alert = app.alerts["Этот раунд окончен!"]
        sleep(3)
        
        XCTAssertTrue(alert.exists)
        sleep(3)
        XCTAssertTrue(alert.label == "Этот раунд окончен!")
        sleep(3)
        XCTAssertTrue(alert.buttons.firstMatch.label == "Сыграть ещё раз")
    }

    func testAlertDismiss() {
        sleep(2)
        for _ in 1...10 {
            app.buttons["No"].tap()
            sleep(2)
        }
        sleep(2)
        let alert = app.alerts["Этот раунд окончен!"]
        sleep(3)
        alert.buttons.firstMatch.tap()
        
        sleep(2)
        
        let indexLabel = app.staticTexts["Index"]
        sleep(3)
        
        XCTAssertFalse(alert.exists)
        sleep(3)
        XCTAssertTrue(indexLabel.label == "1/10")
    }
}
