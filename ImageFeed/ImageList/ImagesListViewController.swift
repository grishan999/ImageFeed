//
//  ViewController.swift
//  ImageFeed
//
//  Created by Ilya Grishanov on 19.12.2024.
//

import UIKit
import Kingfisher

final class ImagesListViewController: UIViewController {
    
    @IBOutlet private var tableView: UITableView!
    
    private var photos: [Photo] = []
    private let photosName: [String] = Array(0..<20).map{ "\($0)" }
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    private var imagesListViewControllerObserver: NSObjectProtocol?
    private let imagesListService = ImagesListService()
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMMM yyyy"
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //fetchPhotosNextPage()
        //        tableView.dataSource = self
        //        tableView.delegate = self
        view.backgroundColor = UIColor(named: "YP Black")
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        tableView.register(ImagesListCell.self, forCellReuseIdentifier: ImagesListCell.reuseIdentifier)
        
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
            
            let image = UIImage(named: photosName[indexPath.row])
            viewController.image = image
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
            // Создаем массив индексов для новых строк
            let indexPaths = (oldCount..<newCount).map { IndexPath(row: $0, section: 0) }
            // Вставляем новые строки в таблицу
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
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)
        
        guard let imageListCell = cell as? ImagesListCell else {
            return UITableViewCell()
        }
        
        configCell(for: imageListCell, with: indexPath)
        
        return imageListCell
    }
}

// настройка ячейки
extension ImagesListViewController {
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        // gолучаем фотографию для текущей строки
        let photo = photos[indexPath.row]
        
        //плейсхолдер
        cell.cellImage.image = UIImage(named: "placeholder")
        
        //индикатор загрузки
        cell.cellImage.kf.indicatorType = .activity
        
        // проверка УРЛ
        if let url = URL(string: photo.thumbImageURL) {
            // подгружаем КФ
            cell.cellImage.kf.setImage(with: url,
                                       //placeholder: UIImage(named: "placeholder"),
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
        
        
        let isLiked = indexPath.row % 2 == 0
        let likeImage = isLiked ? UIImage(named: "Like no active") : UIImage(named: "Like Image")
        cell.likeButton.setImage(likeImage, for: .normal)
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
        imagesListService.fetchPhotos { [weak self] photos in
            DispatchQueue.main.async {
                
                // апдейт массива
                self?.photos = photos
                // релоуд тейбла
                self?.tableView.reloadData()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let image = UIImage(named: photosName[indexPath.row]) else {
            return 0
        }
        
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
        let imageWidth = image.size.width
        let scale = imageViewWidth / imageWidth
        let cellHeight = image.size.height * scale + imageInsets.top + imageInsets.bottom
        return cellHeight
    }
}

