//
//  ViewController.swift
//  ImageFeed
//
//  Created by Ilya Grishanov on 19.12.2024.
//

import Kingfisher
import UIKit

protocol ImagesListCellDelegate: AnyObject {
    func imageListCellDidTapLike(_ cell: ImagesListCell)
}

final class ImagesListViewController: UIViewController {

    @IBOutlet var tableView: UITableView!

    var testTableView: UITableView {
        return tableView
    }

    var presenter: ImagesListPresenterProtocol = ImagesListPresenter()

    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMMM yyyy"
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.view = self
        presenter.fetchPhotosNextPage()
        view.backgroundColor = UIColor(named: "YP Black")
        tableView.contentInset = UIEdgeInsets(
            top: 12, left: 0, bottom: 12, right: 0)

        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 340
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowSingleImage",
            let viewController = segue.destination
                as? SingleImageViewController,
            let indexPath = sender as? IndexPath
        {
            viewController.imageURL = URL(
                string: presenter.getPhoto(at: indexPath.row).largeImageURL)
        }
    }
}

extension ImagesListViewController: ImagesListViewProtocol {
    func updatePhotos() {
        tableView.reloadData()
    }

    func showLikeError() {
        let alert = UIAlertController(
            title: "Ошибка",
            message: "Не удалось изменить лайк",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int)
        -> Int
    {
        return presenter.getPhotosCount()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)
        -> UITableViewCell
    {
        guard
            let cell = tableView.dequeueReusableCell(
                withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)
                as? ImagesListCell
        else {
            return UITableViewCell()
        }

        let photo = presenter.getPhoto(at: indexPath.row)
        cell.setIsLiked(photo.isLiked)
        cell.dateLabel.text = photo.createdAt.map {
            dateFormatter.string(from: $0)
        }
        cell.cellImage.kf.setImage(
            with: URL(string: photo.thumbImageURL),
            placeholder: UIImage(named: "placeholder"))
        cell.delegate = self

        return cell
    }
}

extension ImagesListViewController: UITableViewDelegate {
    func tableView(
        _ tableView: UITableView, willDisplay cell: UITableViewCell,
        forRowAt indexPath: IndexPath
    ) {
        if indexPath.row == presenter.getPhotosCount() - 1 {
            presenter.fetchPhotosNextPage()
        }
    }

    func tableView(
        _ tableView: UITableView, didSelectRowAt indexPath: IndexPath
    ) {
        performSegue(withIdentifier: "ShowSingleImage", sender: indexPath)
    }
}

extension ImagesListViewController: ImagesListCellDelegate {
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        if let indexPath = tableView.indexPath(for: cell) {
            presenter.changeLike(for: indexPath.row)
        }
    }
}
