//
//  ImagesListCell.swift
//  ImageFeed
//
//  Created by Ilya Grishanov on 21.12.2024.
//
import UIKit

final class ImagesListCell: UITableViewCell {
    static let reuseIdentifier = "ImagesListCell"
    
    weak var delegate: ImagesListCellDelegate?
    
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var cellImage: UIImageView!
    
    func setIsLiked(_ isLiked: Bool) {
        DispatchQueue.main.async {
            let likeImage = isLiked ? UIImage(named: "Like Image") : UIImage(named: "Like no active")
            self.likeButton.setImage(likeImage, for: .normal)
            self.likeButton.layoutIfNeeded() // Принудительное обновление layout
        }
    }
    
    @IBAction func likeButtonClicked(_ sender: Any) {
        delegate?.imageListCellDidTapLike(self)
    }
}
