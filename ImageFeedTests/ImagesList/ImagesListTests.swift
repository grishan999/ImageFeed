//
//  ImagesListTests.swift
//  ImageFeed
//
//  Created by Ilya Grishanov on 10.03.2025.
//

import XCTest

@testable import ImageFeed

final class ImagesListViewControllerTests: XCTestCase {
    var viewController: ImagesListViewController!
    var presenterSpy: ImagesListPresenterSpy!

    override func setUp() {
        super.setUp()

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        viewController =
            storyboard.instantiateViewController(
                withIdentifier: "ImagesListViewController")
            as? ImagesListViewController

        presenterSpy = ImagesListPresenterSpy()
        viewController.presenter = presenterSpy

        viewController.loadViewIfNeeded()
    }

    override func tearDown() {
        viewController = nil
        presenterSpy = nil
        super.tearDown()
    }

    func testViewDidLoad() {
        // when
        viewController.viewDidLoad()

        // then
        XCTAssertTrue(presenterSpy.fetchPhotosNextPageCalled)
    }

    func testNumberOfRowsInSection() {
        // given
        let expectedCount = 10

        // when
        let numberOfRows = viewController.tableView.dataSource?.tableView(
            viewController.tableView,
            numberOfRowsInSection: 0
        )

        // then
        XCTAssertEqual(numberOfRows, expectedCount)
        XCTAssertTrue(presenterSpy.getPhotosCountCalled)
    }

    func testWillDisplayCell() {
        // given
        let indexPath = IndexPath(row: 9, section: 0)
        let cell = UITableViewCell()

        // when
        viewController.tableView.delegate?.tableView?(
            viewController.tableView,
            willDisplay: cell,
            forRowAt: indexPath
        )

        // then
        XCTAssertTrue(presenterSpy.fetchPhotosNextPageCalled)
    }
}
