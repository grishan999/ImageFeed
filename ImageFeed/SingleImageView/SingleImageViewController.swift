//
//  SingleImageViewController.swift
//  ImageFeed
//
//  Created by Ilya Grishanov on 27.12.2024.
//

import UIKit

final class SingleImageViewController: UIViewController {
    var image: UIImage? {
           didSet {
               guard isViewLoaded else { return } 
               imageView.image = image
           }
       }
    
    @IBOutlet var imageView: UIImageView!
    
    override func viewDidLoad() {
            super.viewDidLoad()
            imageView.image = image
        }
}
