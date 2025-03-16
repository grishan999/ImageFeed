//
//  ProfilePresenterSpy.swift
//  ImageFeed
//
//  Created by Ilya Grishanov on 09.03.2025.
//
@testable import ImageFeed
import UIKit

final class ProfilePresenterSpy: ProfilePresenterProtocol {
    var view: ProfileViewControllerProtocol?
    
    var viewDidLoadCalled = false
    var didTapExitButtonCalled = false
    var updateAvatarCalled = false
    var updatedAvatarURL: URL?
    
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    
    func didTapExitButton() {
        didTapExitButtonCalled = true
    }

    func updateAvatar(with url: URL) {
        updateAvatarCalled = true
        updatedAvatarURL = url
        view?.updateAvatar(with: url) 
    }
}
