//
//  ProfileTests.swift
//  ImageFeed
//
//  Created by Ilya Grishanov on 09.03.2025.
//

@testable import ImageFeed
import XCTest

final class ProfileTests: XCTestCase {
    func testViewControllerCallsViewDidLoad() {
        // given
        let profilePresenter = ProfilePresenterSpy()
            let profileController = ProfileViewController()
            profileController.presenter = profilePresenter
            
            // when
            profileController.viewDidLoad()
            
            // then
            XCTAssertTrue(profilePresenter.viewDidLoadCalled)
    }
    
    func testViewControllerCallsDidTapExitButton() {
        // given
        let profilePresenter = ProfilePresenterSpy()
        let profileController = ProfileViewController()
        profilePresenter.view = profileController
        profileController.presenter = profilePresenter
        
        // when
        profileController.exitButtonTapped()
        
        // then
        XCTAssertTrue(profilePresenter.didTapExitButtonCalled)
    }


    func testPresenterPresentsAlert() {
        // given
        let profilePresenter = ProfilePresenterSpy()
        let profileController = ProfileViewControllerSpy()
        profilePresenter.view = profileController
        let alert = UIAlertController(title: "Test", message: "Test Message", preferredStyle: .alert)
        
        // when
        profilePresenter.view?.presentAlert(alert)
        
        // then
        XCTAssertTrue(profileController.presentAlertCalled)
        XCTAssertEqual(profileController.presentedAlert, alert)
    }
    
    func testPresenterUpdatesAvatar() {
        // given
        let profilePresenter = ProfilePresenterSpy()
        let profileController = ProfileViewControllerSpy()
        profilePresenter.view = profileController
        let url = URL(string: "https://api.unsplash.com/users")!
        
        // when
        profilePresenter.updateAvatar(with: url)
        
        // then
        XCTAssertTrue(profileController.updateAvatarCalled)
        XCTAssertEqual(profileController.updatedAvatarURL, url)
    }
}

