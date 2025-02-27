//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Ilya Grishanov on 27.12.2024.
//

import UIKit
import Kingfisher

final class ProfileViewController: UIViewController {
    
    private let profileImage = UIImageView()
    private let exitButton = UIButton()
    private let nameLabel = UILabel()
    private  let usernameLabel = UILabel()
    private  let descriptionLabel = UILabel()
    
    private var profileImageServiceObserver: NSObjectProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(named: "YP Black")
        
        //добавление обсервера для нотификаций
        profileImageServiceObserver = NotificationCenter.default
            .addObserver(
                forName: ProfileImageService.didChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                guard let self = self else { return }
                self.updateAvatar()
            }
        updateAvatar()
        
        func updateUI(with profile: Profile) {
            nameLabel.text = profile.name.isEmpty ? "No Name" : profile.name
            usernameLabel.text = profile.loginName
            descriptionLabel.text = profile.bio ?? "No Bio"
        }
        
        guard let token = OAuth2TokenStorage().token else {
            print ("Error getting token")
            return
        }
        
        // проверяем есть ли уже загруженный профиль
        if let profile = ProfileService.shared.profile {
            updateUI(with: profile)
        } else {
            print("Profile not loaded.")
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
    
    private func updateAvatar() {
        guard
            let profileImageURL = ProfileImageService.shared.avatarURL,
            let url = URL(string: profileImageURL)
        else { return }
        
        // делаем изображение круглым
        let processor = BlurImageProcessor(blurRadius: 5.0)
        |> RoundCornerImageProcessor(cornerRadius: 20)
        
        // использование кингфишера для загрузки аватара
        profileImage.kf.setImage(with: url,
                                 placeholder: UIImage(named: "UserPhoto"),
                                 options: [
                                    .processor(processor),
                                    .transition(.fade(3)) // плавный переход при загрузке
                                 ],
                                 completionHandler: { result in
            switch result {
            case .success (let value):
                print("Аватар успешно загружен: \(value.source.url?.absoluteString ?? "Unknown URL")")
            case .failure(let error):
                print("Ошибка при загрузке аватара: \(error.localizedDescription)")
            }
        })
        
    }
    
    @objc private func exitButtonTapped() {
        ProfileLogoutService.shared.logout()
        print ("Профиль обнулен")
    }
}
