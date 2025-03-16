//
//  ImagesListViewControllerSpy.swift
//  ImageFeed
//
//  Created by Ilya Grishanov on 10.03.2025.
//

@testable import ImageFeed
import UIKit

final class ImagesListViewControllerSpy: ImagesListViewProtocol {
    var updatePhotosCalled = false
    var showLikeErrorCalled = false
    
    func updatePhotos() {
        updatePhotosCalled = true
    }
    
    func showLikeError() {
        showLikeErrorCalled = true
    }
}
