//
//  ProfileViewControllerSpy.swift
//  ImageFeed
//
//  Created by Ilya Grishanov on 09.03.2025.
//

import UIKit
@testable import ImageFeed

final class ProfileViewControllerSpy: UIViewController, ProfileViewControllerProtocol {
    var updateUICalled = false
    var updatedProfile: Profile?
    
    var updateAvatarCalled = false
    var updatedAvatarURL: URL?
    
    var presentAlertCalled = false
    var presentedAlert: UIAlertController?
    
    func updateUI(with profile: Profile) {
        updateUICalled = true
        updatedProfile = profile
    }
    
    func updateAvatar(with url: URL) {
        updateAvatarCalled = true
        updatedAvatarURL = url
    }
    
    func presentAlert(_ alert: UIAlertController) {
        presentAlertCalled = true
        presentedAlert = alert
    }
}
