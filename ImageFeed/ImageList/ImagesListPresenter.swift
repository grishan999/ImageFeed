//
//  ImagesListPresenter.swift
//  ImageFeed
//
//  Created by Ilya Grishanov on 09.03.2025.
//

import Kingfisher
import UIKit

protocol ImagesListViewProtocol: AnyObject {
    func updatePhotos()
    func showLikeError()
}

protocol ImagesListPresenterProtocol: AnyObject {
    var view: ImagesListViewProtocol? { get set }
    func fetchPhotosNextPage()
    func changeLike(for index: Int)
    func getPhoto(at index: Int) -> Photo
    func getPhotosCount() -> Int
}


final class ImagesListPresenter: ImagesListPresenterProtocol {
    weak var view: ImagesListViewProtocol?
    private let imagesListService = ImagesListService()
    private var photos: [Photo] = []
    private var imagesListViewControllerObserver: NSObjectProtocol?

    init() {
        imagesListViewControllerObserver = NotificationCenter.default
            .addObserver(
                forName: ImagesListService.didChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                self?.updatePhotos()
            }
    }

    func fetchPhotosNextPage() {
        imagesListService.fetchPhotos { [weak self] newPhotos in
            guard let self = self, !newPhotos.isEmpty else { return }

            DispatchQueue.main.async {
                let uniqueNewPhotos = newPhotos.filter { newPhoto in
                    !self.photos.contains { $0.id == newPhoto.id }
                }
                self.photos.append(contentsOf: uniqueNewPhotos)
                self.view?.updatePhotos()
            }
        }
    }

    func changeLike(for index: Int) {
        let photo = photos[index]
        let newLikeState = !photo.isLiked

        UIBlockingProgressHUD.show()
        imagesListService.changeLike(photoId: photo.id, isLike: newLikeState) {
            [weak self] result in
            DispatchQueue.main.async {
                UIBlockingProgressHUD.dismiss()
                guard let self = self else { return }

                switch result {
                case .success:
                    self.photos[index].isLiked = newLikeState
                    self.view?.updatePhotos()
                case .failure:
                    self.view?.showLikeError()
                }
            }
        }
    }

    func getPhoto(at index: Int) -> Photo {
        photos[index]
    }

    func getPhotosCount() -> Int {
        photos.count
    }

    private func updatePhotos() {
        photos = imagesListService.photos
        view?.updatePhotos()
    }

}
