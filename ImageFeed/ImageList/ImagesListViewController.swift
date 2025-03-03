//
//  ViewController.swift
//  ImageFeed
//
//  Created by Ilya Grishanov on 19.12.2024.
//

import UIKit
import Kingfisher

protocol ImagesListCellDelegate: AnyObject {
    func imageListCellDidTapLike(_ cell: ImagesListCell)
}

final class ImagesListViewController: UIViewController {
    
    @IBOutlet private var tableView: UITableView!
    
    private var photos: [Photo] = []
    private let photosName: [String] = Array(0..<20).map{ "\($0)" }
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    private var imagesListViewControllerObserver: NSObjectProtocol?
    private let imagesListService = ImagesListService()
    
    weak var delegate: ImagesListCellDelegate?
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMMM yyyy"
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchPhotosNextPage()
        
        view.backgroundColor = UIColor(named: "YP Black")
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        
        imagesListViewControllerObserver = NotificationCenter.default
            .addObserver(
                forName: ImagesListService.didChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                guard let self = self else { return }
                self.updatePhotos()
            }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updatePhotos()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showSingleImageSegueIdentifier {
            guard
                let viewController = segue.destination as? SingleImageViewController,
                let indexPath = sender as? IndexPath
            else {
                assertionFailure("Invalid segue destination")
                return
            }
            
            // Получаем URL изображения из массива photos
            let photo = photos[indexPath.row]
            viewController.imageURL = URL(string: photo.largeImageURL)
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    private func updatePhotos() {
        let oldCount = photos.count
        let newCount = imagesListService.photos.count
        photos = imagesListService.photos
        
        print("Updating photos. Old count: \(oldCount), new count: \(newCount)")
        
        tableView.performBatchUpdates{
            // создаем массив индексов для новых строк
            let indexPaths = (oldCount..<newCount).map { IndexPath(row: $0, section: 0) }
            // вставляем новые строки в таблицу
            tableView.insertRows(at: indexPaths, with: .automatic)
        } completion: { _ in
        }
        print("Updating photos. Old count: \(oldCount), new count: \(newCount)")
    }
}

extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath) as? ImagesListCell else {
            return UITableViewCell()
        }
        
        configCell(for: cell, with: indexPath)
        cell.delegate = self // Устанавливаем делегат
        
        return cell
    }
}

// настройка ячейки
extension ImagesListViewController {
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        // получаем фотографию для текущей строки
        let photo = photos[indexPath.row]
        
        //плейсхолдер
        cell.cellImage.image = UIImage(named: "placeholder")
        
        cell.setIsLiked(photo.isLiked)
        
        //индикатор загрузки
        cell.cellImage.kf.indicatorType = .activity
        
        // проверка УРЛ
        if let url = URL(string: photo.thumbImageURL) {
            // подгружаем КФ
            cell.cellImage.kf.setImage(with: url,
                                       placeholder: UIImage(named: "placeholder"),
                                       options: [.transition(.fade(1))]
            ) { [weak self] result in
                // обработка результата
                guard let self = self else { return }
                
                switch result {
                case .success:
                    //обновление высоты ячейки (автоматическое под размер )
                    self.tableView.reloadRows(at: [indexPath], with: .automatic)
                case .failure(let error):
                    print("Error downloading image: \(error)")
                }
            }
        }
        cell.dateLabel.text = photo.createdAt.map { dateFormatter.string(from: $0) }
    }
}

extension ImagesListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        // отображение следующей страницы, если отображается последняя ячейка
        if indexPath.row == photos.count - 1 {
            fetchPhotosNextPage()
        }
    }
    
    // загрузка следующей страницы фотографий
    private func fetchPhotosNextPage() {
        imagesListService.fetchPhotos { [weak self] newPhotos in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                let oldCount = self.photos.count
                self.photos.append(contentsOf: newPhotos)
                let newCount = self.photos.count
                
                self.tableView.performBatchUpdates {
                    let indexPaths = (oldCount..<newCount).map { IndexPath(row: $0, section: 0) }
                    self.tableView.insertRows(at: indexPaths, with: .automatic)
                } completion: { _ in }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let photo = photos[indexPath.row]
        
        // используем размер изображения из photo
        let imageSize = CGSize(width: photo.size.width, height: photo.size.height)
        
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
        let scale = imageViewWidth / imageSize.width
        let cellHeight = imageSize.height * scale + imageInsets.top + imageInsets.bottom
        return cellHeight
    }
}

extension ImagesListViewController: ImagesListCellDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // вызываем сегвей, передавая indexPath как sender
        performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: indexPath)
    }
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        
        let photo = photos[indexPath.row]
        let newLikeState = !photo.isLiked
        
        // обновление UI
        photos[indexPath.row].isLiked = newLikeState
        cell.setIsLiked(newLikeState)
        
        UIBlockingProgressHUD.show()
        imagesListService.changeLike(photoId: photo.id, isLike: newLikeState) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                UIBlockingProgressHUD.dismiss()
                switch result {
                case .success:
                    // обновление состояния в основном массиве
                    if let updatedPhotoIndex = self.photos.firstIndex(where: { $0.id == photo.id }) {
                        self.photos[updatedPhotoIndex].isLiked = newLikeState
                        self.tableView.reloadRows(at: [IndexPath(row: updatedPhotoIndex, section: 0)], with: .automatic)
                    }
                case .failure:
                    // откат изменений
                    self.photos[indexPath.row].isLiked.toggle()
                    cell.setIsLiked(self.photos[indexPath.row].isLiked)
                    
                    let alert = UIAlertController(
                        title: "Ошибка",
                        message: "Не удалось изменить лайк",
                        preferredStyle: .alert
                    )
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(alert, animated: true)
                }
            }
        }
    }
}
