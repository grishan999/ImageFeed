//
//  ImageFeedUITests.swift
//  ImageFeedUITests
//
//  Created by Ilya Grishanov on 10.03.2025.
//

import XCTest

final class ImageFeedUITests: XCTestCase {

    private let app = XCUIApplication()

    override func setUpWithError() throws {
        continueAfterFailure = false

        app.launch()
    }

    func testAuth() throws {
        if !app.buttons["Auth"].exists {
            app.tabBars.buttons.element(boundBy: 1).tap()
            app.buttons["exitButton"].tap()
            app.alerts["Пока, пока!"].scrollViews.otherElements.buttons["Да"]
                .tap()
        }

        let authButton = app.buttons["Auth"]
        XCTAssertTrue(authButton.waitForExistence(timeout: 5))
        authButton.tap()
        sleep(8)

        let webView = app.webViews["UnsplashWebView"]
        XCTAssertTrue(webView.waitForExistence(timeout: 15))

        let loginTextField = webView.descendants(matching: .textField).element
        XCTAssertTrue(loginTextField.exists, "Поле логина не найдено")
        loginTextField.tap()
        loginTextField.typeText("LOGIN")
        webView.swipeUp()

        let passwordTextField = webView.descendants(matching: .secureTextField)
            .element
        XCTAssertTrue(passwordTextField.waitForExistence(timeout: 10))
        passwordTextField.tap()
        sleep(2)

        passwordTextField.tap()
        passwordTextField.typeText("PASSWORD")
        webView.swipeUp()

        let loginButton = webView.buttons["Login"]
        XCTAssertTrue(loginButton.exists)
        loginButton.tap()

        let table = app.tables.element
        XCTAssertTrue(table.waitForExistence(timeout: 30))

        // Проверяем, загружены ли ячейки
        let cell = table.cells.element(boundBy: 0)
        XCTAssertTrue(cell.waitForExistence(timeout: 15))
    }

    func testFeed() throws {
        let tablesQuery = app.tables

        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        cell.swipeUp()

        sleep(2)

        let cellToLike = tablesQuery.children(matching: .cell).element(
            boundBy: 1)

        cellToLike.buttons["like button"].tap()

        sleep(2)

        cellToLike.tap()

        sleep(2)

        let image = app.scrollViews.images.element(boundBy: 0)
        image.pinch(withScale: 3, velocity: 1)
        image.pinch(withScale: 0.5, velocity: -1)

        let navBackButtonWhiteButton = app.buttons["nav back button"]
        navBackButtonWhiteButton.tap()
    }

    func testProfile() throws {
        sleep(3)
        app.tabBars.buttons.element(boundBy: 1).tap()

        sleep(10)
        XCTAssertTrue(app.staticTexts["nameLabel"].exists)
        XCTAssertTrue(app.staticTexts["usernameLabel"].exists)
        XCTAssertTrue(app.staticTexts["descriptionLabel"].exists)

        app.buttons["exitButton"].tap()
        sleep(5)
        app.alerts["Пока, пока!"].scrollViews.otherElements.buttons["Да"].tap()
    }

}
