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
        app.buttons["Auth"].tap()

        let webView = app.webViews["UnsplashWebView"]

        XCTAssertTrue(webView.waitForExistence(timeout: 5))

        let loginTextField = webView.descendants(matching: .textField).element
        XCTAssertTrue(loginTextField.waitForExistence(timeout: 5))

        loginTextField.tap()
        loginTextField.typeText("")
        webView.swipeUp()

        let passwordTextField = webView.descendants(matching: .secureTextField)
            .element
        XCTAssertTrue(passwordTextField.waitForExistence(timeout: 5))

        passwordTextField.tap()
        passwordTextField.typeText("")
        webView.swipeUp()

        webView.buttons["Login"].tap()

        let tablesQuery = app.tables
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)

        XCTAssertTrue(cell.waitForExistence(timeout: 5))
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

        let scrollView = app.scrollViews.element
        XCTAssertTrue(scrollView.waitForExistence(timeout: 5))

        let image = scrollView.images.element(boundBy: 0)
        XCTAssertTrue(image.waitForExistence(timeout: 5))

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
