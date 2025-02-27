//
//  SingleImageViewController.swift
//  ImageFeed
//
//  Created by Ilya Grishanov on 27.12.2024.
//

import UIKit

final class SingleImageViewController: UIViewController {
    // MARK: - Public Variables
    var imageURL: URL? {
        didSet {
            guard isViewLoaded, let imageURL else { return }
            loadImage(from: imageURL)
        }
        
    }
    
    // MARK: - IBOutlets
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet private var imageView: UIImageView!
    
    // MARK: - Private Methods
    private func rescaleAndCenterImageInScrollView(image: UIImage) {
        // Устанавливаем размер imageView равным размеру изображения
        imageView.frame = CGRect(origin: .zero, size: image.size)
        
        // Устанавливаем contentSize scrollView равным размеру изображения
        scrollView.contentSize = image.size
        
        // Вычисляем масштаб для правильного отображения изображения
        let minZoomScale = scrollView.minimumZoomScale
        let maxZoomScale = scrollView.maximumZoomScale
        let visibleRectSize = scrollView.bounds.size
        let imageSize = image.size
        
        // Вычисляем масштаб для заполнения scrollView
        let hScale = visibleRectSize.width / imageSize.width
        let vScale = visibleRectSize.height / imageSize.height
        let scale = min(maxZoomScale, max(minZoomScale, max(hScale, vScale)))
        
        // Устанавливаем zoomScale
        scrollView.setZoomScale(scale, animated: false)
        
        // Центрируем изображение
        let offsetX = max((scrollView.contentSize.width - scrollView.bounds.width) / 2, 0)
        let offsetY = max((scrollView.contentSize.height - scrollView.bounds.height) / 2, 0)
        scrollView.setContentOffset(CGPoint(x: offsetX, y: offsetY), animated: false)
    }
    
    private func loadImage(from url: URL) {
        imageView.kf.indicatorType = .activity // Показываем индикатор загрузки
        imageView.kf.setImage(with: url) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let value):
                // После успешной загрузки масштабируем и центрируем изображение
                self.rescaleAndCenterImageInScrollView(image: value.image)
            case .failure(let error):
                print("Ошибка загрузки изображения: \(error)")
            }
        }
    }
    
    // MARK: - Public Methods
    override func viewDidLoad() {
        scrollView.delegate = self
        
        super.viewDidLoad()
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 1.25
        
        if let imageURL = imageURL {
            loadImage(from: imageURL)
        }
    }
    
    // MARK: - IBActions
    @IBAction func didTapShareButton(_ sender: Any) {
        guard let image = imageView.image else { return }
        let share = UIActivityViewController(
            activityItems: [image],
            applicationActivities: nil
        )
        present(share, animated: true, completion: nil)
    }
    
    @IBAction private func didTapBackButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}

// MARK: - UIScrollViewDelegate
extension SingleImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        imageView
    }
}
