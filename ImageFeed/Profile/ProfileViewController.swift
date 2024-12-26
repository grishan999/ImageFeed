//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Ilya Grishanov on 27.12.2024.
//

import UIKit

final class ProfileViewController: UIViewController {
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var loginLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    
    @IBOutlet weak var exitButton: UIButton!
    
    @IBAction func didTapExitButton(_ sender: Any) {
    }
    
}
