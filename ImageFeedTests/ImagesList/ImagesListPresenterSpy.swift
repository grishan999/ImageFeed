//
//  ImagesListPresenterSpy.swift
//  ImageFeed
//
//  Created by Ilya Grishanov on 10.03.2025.
//

@testable import ImageFeed
import UIKit

final class ImagesListPresenterSpy: ImagesListPresenterProtocol {
    weak var view: ImagesListViewProtocol?
    
    var fetchPhotosNextPageCalled = false
    var changeLikeCalled = false
    var getPhotoCalled = false
    var getPhotosCountCalled = false
    
    func fetchPhotosNextPage() {
        fetchPhotosNextPageCalled = true
    }
    
    func changeLike(for index: Int) {
        changeLikeCalled = true
    }
    
    func getPhoto(at index: Int) -> Photo {
        getPhotoCalled = true
        return Photo(id: "test", size: CGSize(width: 100, height: 100), createdAt: Date(), welcomeDescription: "Test", thumbImageURL: "https://example.com/thumb.jpg", largeImageURL: "https://example.com/large.jpg", isLiked: false)
    }
    
    func getPhotosCount() -> Int {
        getPhotosCountCalled = true
        return 10
    }
}
