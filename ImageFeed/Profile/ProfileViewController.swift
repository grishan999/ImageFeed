//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Ilya Grishanov on 27.12.2024.
//

import UIKit

final class ProfileViewController: UIViewController {
    
    let profileImage = UIImageView()
    let exitButton = UIButton()
    let nameLabel = UILabel()
    let usernameLabel = UILabel()
    let descriptionLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let token = OAuth2TokenStorage().token else {
            print ("Error getting token")
            return
        }
        
        ProfileService().fetchProfile(token: token) { [weak self] result in
                    switch result {
                    case .success(let profile):
                        DispatchQueue.main.async {
                            self?.nameLabel.text = profile.name.isEmpty ? "No Name" : profile.name
                            self?.usernameLabel.text = profile.loginName
                            self?.descriptionLabel.text = profile.bio ?? "No Bio"
                        }
                    case .failure(let error):
                        print("Error fetching profile: \(error)")
                    }
                }
        
        //ProfileImage
        profileImage.image = UIImage(named: "UserPhoto")
        profileImage.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(profileImage)
        
        NSLayoutConstraint.activate ([
            profileImage.heightAnchor.constraint(equalToConstant: 70),
            profileImage.widthAnchor.constraint(equalToConstant: 70),
            profileImage.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            profileImage.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
        ])
        
        //ExitButton
        exitButton.setImage(UIImage(named: "Exit"), for: .normal)
        exitButton.translatesAutoresizingMaskIntoConstraints = false
        exitButton.addTarget(self, action: #selector(exitButtonTapped), for: .touchUpInside)
        view.addSubview(exitButton)
        
        
        NSLayoutConstraint.activate ([
            exitButton.heightAnchor.constraint(equalToConstant: 24),
            exitButton.widthAnchor.constraint(equalToConstant: 24),
            exitButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -26),
            exitButton.centerYAnchor.constraint(equalTo: profileImage.centerYAnchor)
            
        ])
        
        //NameLabel
        nameLabel.text = "Екатерина Новикова"
        nameLabel.textColor = UIColor(named: "YP White")
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nameLabel)
        
        nameLabel.font = UIFont.systemFont(ofSize: 23, weight: .bold)
        
        NSLayoutConstraint.activate ([
            nameLabel.topAnchor.constraint(equalTo: profileImage.bottomAnchor, constant: 8),
            nameLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            nameLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
        ])
        
        //UserNameLabel
        usernameLabel.text = "@ekaterina_nov"
        usernameLabel.textColor = UIColor(named: "YP Grey")
        usernameLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(usernameLabel)
        
        usernameLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        
        NSLayoutConstraint.activate ([
            usernameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            usernameLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
        ])
        
        //DescriptionLabel
        descriptionLabel.text = "Hello, world!"
        descriptionLabel.textColor = UIColor(named: "YP White")
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(descriptionLabel)
        
        descriptionLabel.numberOfLines = 0
        
        usernameLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        
        NSLayoutConstraint.activate ([
            descriptionLabel.topAnchor.constraint(equalTo: usernameLabel.bottomAnchor, constant: 8),
            descriptionLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            descriptionLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
        ])
    }
    
    @objc private func exitButtonTapped() {}
}
