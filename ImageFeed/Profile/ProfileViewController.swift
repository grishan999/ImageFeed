//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Ilya Grishanov on 27.12.2024.
//

import Kingfisher
import UIKit

protocol ProfileViewControllerProtocol: AnyObject {
    func updateUI(with profile: Profile)
    func updateAvatar(with url: URL)
    func presentAlert(_ alert: UIAlertController)
}

final class ProfileViewController: UIViewController,
                                   ProfileViewControllerProtocol
{
    private let profileImage = UIImageView()
    private let exitButton = UIButton()
    let nameLabel = UILabel()
    let usernameLabel = UILabel()
    let descriptionLabel = UILabel()
    
    var presenter: ProfilePresenterProtocol
    
    init(presenter: ProfilePresenterProtocol = ProfilePresenter()) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
        self.presenter.view = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(_ presenter: ProfilePresenterProtocol) {
        self.presenter = presenter
        presenter.view = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "YP Black")
        setupUI()
        presenter.viewDidLoad()
    }
    
    func updateUI(with profile: Profile) {
        print("Обновление UI с профилем: \(profile)")
        DispatchQueue.main.async {
            self.nameLabel.text =
            profile.name.isEmpty ? "No Name" : profile.name
            self.usernameLabel.text = profile.loginName
            self.descriptionLabel.text = profile.bio ?? "No Bio"
        }
    }
    
    func updateAvatar(with url: URL) {
        print("Обновление аватара с URL: \(url)")
        DispatchQueue.main.async {
            let processor =
            BlurImageProcessor(blurRadius: 5.0)
            |> RoundCornerImageProcessor(cornerRadius: 20)
            self.profileImage.kf.setImage(
                with: url,
                placeholder: UIImage(named: "UserPhoto"),
                options: [.processor(processor), .transition(.fade(3))]
            )
        }
    }
    
    func presentAlert(_ alert: UIAlertController) {
        present(alert, animated: true, completion: nil)
    }
    
    @objc func exitButtonTapped() {
        presenter.didTapExitButton()
    }
    
    private func setupUI() {
        profileImage.image = UIImage(named: "UserPhoto")
        profileImage.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(profileImage)
        
        NSLayoutConstraint.activate([
            profileImage.heightAnchor.constraint(equalToConstant: 70),
            profileImage.widthAnchor.constraint(equalToConstant: 70),
            profileImage.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            profileImage.leadingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
        ])
        
        exitButton.setImage(UIImage(named: "Exit"), for: .normal)
        exitButton.accessibilityIdentifier = "exitButton"
        exitButton.translatesAutoresizingMaskIntoConstraints = false
        exitButton.addTarget(
            self, action: #selector(exitButtonTapped), for: .touchUpInside)
        view.addSubview(exitButton)
        
        NSLayoutConstraint.activate([
            exitButton.heightAnchor.constraint(equalToConstant: 24),
            exitButton.widthAnchor.constraint(equalToConstant: 24),
            exitButton.trailingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -26),
            exitButton.centerYAnchor.constraint(
                equalTo: profileImage.centerYAnchor),
        ])
        
        nameLabel.textColor = UIColor(named: "YP White")
        nameLabel.accessibilityIdentifier = "nameLabel"
        nameLabel.font = UIFont.systemFont(ofSize: 23, weight: .bold)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nameLabel)
        
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(
                equalTo: profileImage.bottomAnchor, constant: 8),
            nameLabel.leadingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            nameLabel.trailingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
        ])
        
        usernameLabel.textColor = UIColor(named: "YP Grey")
        usernameLabel.accessibilityIdentifier = "usernameLabel"
        usernameLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        usernameLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(usernameLabel)
        
        NSLayoutConstraint.activate([
            usernameLabel.topAnchor.constraint(
                equalTo: nameLabel.bottomAnchor, constant: 8),
            usernameLabel.leadingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
        ])
        
        descriptionLabel.textColor = UIColor(named: "YP White")
        descriptionLabel.accessibilityIdentifier = "descriptionLabel"
        descriptionLabel.numberOfLines = 0
        descriptionLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(descriptionLabel)
        
        NSLayoutConstraint.activate([
            descriptionLabel.topAnchor.constraint(
                equalTo: usernameLabel.bottomAnchor, constant: 8),
            descriptionLabel.leadingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            descriptionLabel.trailingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
        ])
    }
}
