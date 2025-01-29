//
//  ImagesListCell.swift
//  ImageFeed
//
//  Created by Ilya Grishanov on 21.12.2024.
//
import UIKit

final class ImagesListCell: UITableViewCell {
    static let reuseIdentifier = "ImagesListCell"
    
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var cellImage: UIImageView!

}
