//
//  SingleImageViewController.swift
//  ImageFeed
//
//  Created by Ilya Grishanov on 27.12.2024.
//

import UIKit
import Kingfisher
import ProgressHUD

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
        // устанавливаем размер imageView равным размеру изображения
        imageView.frame = CGRect(origin: .zero, size: image.size)
        
        // устанавливаем contentSize scrollView равным размеру изображения
        scrollView.contentSize = image.size
        
        // вычисляем масштаб для правильного отображения изображения
        let minZoomScale = scrollView.minimumZoomScale
        let maxZoomScale = scrollView.maximumZoomScale
        let visibleRectSize = scrollView.bounds.size
        let imageSize = image.size
        
        // вычисляем масштаб для заполнения scrollView
        let hScale = visibleRectSize.width / imageSize.width
        let vScale = visibleRectSize.height / imageSize.height
        let scale = min(maxZoomScale, max(minZoomScale, max(hScale, vScale)))
        
        // устанавливаем zoomScale
        scrollView.setZoomScale(scale, animated: false)
        
        // центрируем изображение
        let offsetX = max((scrollView.contentSize.width - scrollView.bounds.width) / 2, 0)
        let offsetY = max((scrollView.contentSize.height - scrollView.bounds.height) / 2, 0)
        scrollView.setContentOffset(CGPoint(x: offsetX, y: offsetY), animated: false)
    }
    
    private let placeholderSize = CGSize(width: 83, height: 75)
    
    private func loadImage(from url: URL) {
        let placeholderImage = UIImage(named: "SinglePlaceholder")
        ProgressHUD.show()
        
        // Устанавливаем размер imageView равным размеру плейсхолдера
        imageView.frame.size = placeholderSize
        
        // Центрируем imageView внутри scrollView
        imageView.center = CGPoint(
            x: scrollView.bounds.midX,
            y: scrollView.bounds.midY
        )
        
        imageView.kf.setImage(
            with: url,
            placeholder: placeholderImage,
            options: [.transition(.fade(0.2))]
        ) { [weak self] result in
            guard let self = self else { return }
            ProgressHUD.dismiss()
            
            switch result {
            case .success(let value):
                self.rescaleAndCenterImageInScrollView(image: value.image)
                self.imageView.contentMode = .scaleAspectFill
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
        imageView.contentMode = .center
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
