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
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBAction private func didTapBackButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    

    @IBOutlet private var imageView: UIImageView!
    
    
    override func viewDidLoad() {
            super.viewDidLoad()
            imageView.image = image
        }
}
