//
//  ProfilePresenterSpy.swift
//  ImageFeed
//
//  Created by Ilya Grishanov on 09.03.2025.
//

import ImageFeed
import Foundation

final class ProfilePresenterSpy: ProfilePresenterProtocol {
    weak var view: ProfileViewControllerProtocol?
    
    var viewDidLoadCalled = false
    var didTapExitButtonCalled = false
    
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    
    func didTapExitButton() {
        didTapExitButtonCalled = true
    }
}
